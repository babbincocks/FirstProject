USE master
IF (SELECT COUNT(*) FROM sys.databases WHERE name = 'LibraryTest') > 0
BEGIN
DROP DATABASE LibraryTest
END

CREATE DATABASE LibraryTest

GO

USE LibraryTest

CREATE TABLE Person 
(	PersonID INT NOT NULL IDENTITY(1,1),
	PersonType VARCHAR(5) NOT NULL,
	Title VARCHAR(10) NULL,
	FirstName VARCHAR(35) NOT NULL,
	MidName VARCHAR(35) NULL,
	LastName VARCHAR(35) NOT NULL,
	Suffix VARCHAR(8) NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_Person_PersonID PRIMARY KEY (PersonID)
)

		CREATE INDEX ind_FirstName ON Person(FirstName);
		CREATE INDEX ind_LastName ON Person(LastName);

CREATE TABLE Media
(	MediaID INT NOT NULL IDENTITY(1,1),
	Medium VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Media_MediaID PRIMARY KEY (MediaID)
)
		
		CREATE INDEX ind_Medium ON Media(Medium);

CREATE TABLE LibraryCard
(	LibCardID INT NOT NULL IDENTITY(1001,1),
	SerialNumber INT NOT NULL,
	ExpirationDate DATE NOT NULL,
	SignUpDate DATE NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_LibraryCard_LibCardID PRIMARY KEY (LibCardID),
	CONSTRAINT CK_SignUpFuture CHECK (SignUpDate <= GETDATE()),
	CONSTRAINT CK_ExpireSignUp CHECK (ExpirationDate >= DATEADD(MONTH,6, SignUpDate))
)
CREATE TABLE AddressWhole
(	AddressID INT NOT NULL IDENTITY(1,1),
	AddressLine1 NVARCHAR(50) NOT NULL,
	AddressLine2 NVARCHAR(30) NULL,
	City NVARCHAR(20) NOT NULL,
	Region NVARCHAR(30) NULL,
	Country NVARCHAR(30) NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_AddressWhole_AddressID PRIMARY KEY (AddressID)
)
		
		CREATE INDEX ind_Address1 ON AddressWhole(AddressLine1)
		CREATE INDEX ind_City ON AddressWhole(City)
		CREATE INDEX ind_Region ON AddressWhole(Region)

CREATE TABLE DeweyDecimal
(	DDNumber INT NOT NULL IDENTITY(000,1),
	Class VARCHAR(50) NOT NULL,
	Division VARCHAR(80) NOT NULL,
	Section VARCHAR(150) NOT NULL,
	CONSTRAINT PK_DeweyDecimal_DDNumber PRIMARY KEY (DDNumber)
)

		CREATE INDEX ind_Class ON DeweyDecimal(Class)
		CREATE INDEX ind_Division ON DeweyDecimal (Division)
		CREATE INDEX ind_Section ON DeweyDecimal(Section)

--Restriction: 0 = All ages, 1 = Must be at least 13 or have guardian permission, 2 = Must be at least 18 or have guardian permission
--Removal: 0 = Not set for removal, 1 = Set for removal, 2 = Removed.
CREATE TABLE Publications
(	PubID INT NOT NULL IDENTITY(1,1),
	PubName VARCHAR(80) NOT NULL,
	DDNumber INT NULL,
	AuthorID INT NULL,
	ReleaseDate DATE NULL,
	MediaID INT NOT NULL,
	Restriction TINYINT NOT NULL,
	Removal TINYINT NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_Publications_PubID PRIMARY KEY (PubID),
	CONSTRAINT FK_Publications_DeweyDecimal FOREIGN KEY (DDNumber) REFERENCES DeweyDecimal(DDNumber),
	CONSTRAINT FK_Publications_Person FOREIGN KEY (AuthorID) REFERENCES Person(PersonID),
	CONSTRAINT FK_Publications_Media FOREIGN KEY (MediaID) REFERENCES Media(MediaID)
);
CREATE INDEX ind_PubName ON Publications(PubName)

CREATE TABLE PubInventory
(	PubID INT NOT NULL,
	UnitsIn INT NOT NULL,
	UnitsOut INT NOT NULL,
	Shelved INT NOT NULL,
	UnitPrice SMALLMONEY NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN(),
	CONSTRAINT PK_PubInventory_PubID PRIMARY KEY (PubID),
	CONSTRAINT FK_PubInventory_Publications FOREIGN KEY (PubID) REFERENCES Publications(PubID)
)
;
CREATE INDEX ind_Shelved ON PubInventory(Shelved)

;

CREATE TABLE Phone
(	PersonID INT NOT NULL,
	Phone VARCHAR(25) NOT NULL,
	PhoneType VARCHAR(20) NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_Phone_PersonID_Phone PRIMARY KEY (PersonID, Phone),
	CONSTRAINT FK_Phone_Person FOREIGN KEY (PersonID) REFERENCES Person(PersonID)
)
;

		CREATE INDEX ind_PhoneType ON Phone(PhoneType)

CREATE TABLE Suppliers
(	SupplierID INT NOT NULL IDENTITY (1,1),
	CompanyName VARCHAR(65) NOT NULL,
	AddressID INT NULL,
	ActiveFlag BIT NOT NULL,
	ContactID INT NOT NULL,
	ContactTitle VARCHAR(40) NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_Suppliers_SupplierID PRIMARY KEY (SupplierID),
	CONSTRAINT FK_Suppliers_AddressWhole FOREIGN KEY (AddressID) REFERENCES AddressWhole(AddressID),
	CONSTRAINT FK_Suppliers_Person FOREIGN KEY (ContactID) REFERENCES Person(PersonID)
);
		CREATE INDEX ind_CompanyName ON Suppliers(CompanyName)
		CREATE INDEX ind_Contact ON Suppliers(ContactID)
;

CREATE TABLE PersonAddress
(	PersonID INT NOT NULL,
	AddressID INT NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_PersonAddress_PersonID_AddressID PRIMARY KEY (PersonID, AddressID),
	CONSTRAINT FK_PersonAddress_Person FOREIGN KEY (PersonID) REFERENCES Person(PersonID),
	CONSTRAINT FK_PersonAddress_Address FOREIGN KEY (AddressID) REFERENCES AddressWhole(AddressID)
);

CREATE TABLE EmailAddress
(	EmailID INT NOT NULL IDENTITY(1,1),
	PersonID INT NOT NULL,
	EmailAddress VARCHAR(70) NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_EmailAddress_EmailID PRIMARY KEY(EmailID),
	CONSTRAINT FK_EmailAddress_Person FOREIGN KEY (PersonID) REFERENCES Person(PersonID)
);
CREATE INDEX ind_EmailAddress ON Emailaddress(EmailAddress);

CREATE TABLE Customers
(	CustID INT NOT NULL,
	LibCardID INT NULL,
	Age TINYINT NULL,
	EmailID INT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_Customers_CustID PRIMARY KEY (CustID),
	CONSTRAINT FK_Customers_Person FOREIGN KEY (CustID) REFERENCES Person(PersonID),
	CONSTRAINT FK_Customers_LibraryCard FOREIGN KEY (LibCardID) REFERENCES LibraryCard(LibCardID),
	CONSTRAINT FK_Customers_EmailAddress FOREIGN KEY (EmailID) REFERENCES EmailAddress(EmailID)
);
CREATE INDEX ind_LibCard ON Customers(LibCardID);


CREATE TABLE Employees
(	EmployeeID INT NOT NULL,
	LoginID VARCHAR(10) NULL,
	JobTitle VARCHAR(30) NOT NULL,
	CurrentFlag BIT NOT NULL,
	EmailID INT NOT NULL,
	BirthDate DATE NOT NULL,
	HireDate DATE NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_Employees_EmployeeID PRIMARY KEY (EmployeeID),
	CONSTRAINT FK_Employees_Person FOREIGN KEY (EmployeeID) REFERENCES Person(PersonID),
	CONSTRAINT FK_Employees_EmailAddress FOREIGN KEY (EmailID) REFERENCES EmailAddress(EmailID)
);


CREATE TABLE PubTracking
(	TrackID INT NOT NULL IDENTITY(1,1),
	CustID INT NOT NULL,
	OutDate DATE NOT NULL,
	InDate DATE NULL,
	DueDate DATE NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_PubTracking_TrackID PRIMARY KEY (TrackID),
	CONSTRAINT FK_PubTracking_Customers FOREIGN KEY (CustID) REFERENCES Customers(CustID)
);
CREATE INDEX ind_CustID ON PubTracking(CustID);
CREATE INDEX ind_InDate ON PubTracking(InDate);
CREATE INDEX ind_DueDate ON PubTracking(DueDate);

CREATE TABLE TrackingDetails
(	TrackDetailID INT NOT NULL IDENTITY(1,1),
	TrackID INT NOT NULL,
	PubID INT NOT NULL,
	Quantity SMALLINT NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_TrackingDetails_TrackDetailID_TrackID PRIMARY KEY (TrackDetailID, TrackID),
	CONSTRAINT FK_TrackingDetails_PubTracking FOREIGN KEY (TrackID) REFERENCES PubTracking(TrackID),
	CONSTRAINT FK_TrackingDetails_Publications FOREIGN KEY (PubID) REFERENCES Publications(PubID)
);
CREATE INDEX ind_TrackID ON TrackingDetails(TrackID);
CREATE INDEX ind_PubID ON TrackingDetails(PubID);
CREATE INDEX ind_Quantity ON TrackingDetails(Quantity);

CREATE TABLE Orders
(	OrderID INT NOT NULL IDENTITY(1,1),
	SupplierID INT NOT NULL,
	OrderDate DATE NOT NULL,
	ShipDate DATE NOT NULL,
	[Status] BIT NOT NULL,
	SubTotal MONEY NOT NULL,
	Tax MONEY NOT NULL,
	Shipping MONEY NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_Orders_OrderID PRIMARY KEY (OrderID),
	CONSTRAINT FK_Orders_Suppliers FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);
CREATE INDEX ind_OrderDate ON Orders(OrderDate);
CREATE INDEX ind_ShipDate ON Orders(ShipDate);
CREATE INDEX ind_SubTotal ON Orders(SubTotal);
CREATE INDEX ind_Tax ON Orders(Tax);
CREATE INDEX ind_Shipping ON Orders(Shipping);


CREATE TABLE OrderDetails
(	OrderDetailID INT NOT NULL IDENTITY(1,1),
	OrderID INT NOT NULL,
	PubID INT NOT NULL,
	OrderQty SMALLINT NOT NULL,
	ReceivedQty SMALLINT NOT NULL,
	RejectedQty SMALLINT NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_OrderDetails_OrderDetailID_OrderID PRIMARY KEY (OrderDetailID, OrderID),
	CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
	CONSTRAINT FK_OrderDetails_Publications FOREIGN KEY (PubID) REFERENCES Publications(PubID)
);
CREATE INDEX ind_OrderID ON OrderDetails(OrderID);
CREATE INDEX ind_OrderQty ON OrderDetails(OrderQty);
CREATE INDEX ind_ReceivedQty ON OrderDetails(ReceivedQty);
CREATE INDEX ind_RejectedQty ON OrderDetails(RejectedQty);

CREATE TABLE Fees
(	FeeID INT NOT NULL IDENTITY(1,1),
	TrackID INT NOT NULL,
	PubID INT NOT NULL,
	CustID INT NOT NULL,
	Overdue BIT NOT NULL,
	Damage BIT NOT NULL,
	CompAmount SMALLMONEY NOT NULL,
	CompDue DATE NOT NULL,
	CompPaid SMALLMONEY NOT NULL,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(), 
	ModifiedBy VARCHAR(20) NOT NULL DEFAULT ORIGINAL_LOGIN()
	CONSTRAINT PK_Fees_FeeID PRIMARY KEY (FeeID),
	CONSTRAINT FK_Fees_PubTracking FOREIGN KEY (TrackID) REFERENCES PubTracking(TrackID),
	CONSTRAINT FK_Fees_Publications FOREIGN KEY (PubID) REFERENCES Publications(PubID),
	CONSTRAINT FK_Fees_Customers FOREIGN KEY (CustID) REFERENCES Customers(CustID),
	CONSTRAINT CK_FeeReason CHECK (Overdue <> 0 OR Damage <> 0)
)
;
CREATE INDEX ind_TrackID ON Fees(TrackID);
CREATE INDEX ind_PubID ON Fees(PubID);
CREATE INDEX ind_CustID ON Fees(CustID);
CREATE INDEX ind_CompAmount ON Fees(CompAmount);
CREATE INDEX ind_CompDue ON Fees(CompDue);
CREATE INDEX ind_CompPaid ON Fees(CompPaid);
;
GO
CREATE TRIGGER trg_ModPersonRecord 
ON Person
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT PersonID FROM inserted) 
		UPDATE Person
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  PersonID = @insert
END
GO
;
CREATE TRIGGER trg_ModLibCardRecord 
ON LibraryCard
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT LibCardID FROM inserted) 
		UPDATE LibraryCard
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  LibCardID = @insert
END
GO
;
CREATE TRIGGER trg_ModAddressRecord 
ON AddressWhole
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT AddressID FROM inserted) 
		UPDATE AddressWhole
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  AddressID = @insert
END
GO
;
CREATE TRIGGER trg_ModPubsRecord 
ON Publications
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT PubID FROM inserted) 
		UPDATE Publications
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  PubID = @insert
END
GO
;
CREATE TRIGGER trg_ModPubInvRecord 
ON PubInventory
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT PubID FROM inserted) 
		UPDATE PubInventory
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  PubID = @insert
END
GO
;
CREATE TRIGGER trg_ModPhoneRecord 
ON Phone
AFTER UPDATE
AS
BEGIN
	DECLARE @insert VARCHAR(25)
	SET @insert = (SELECT Phone FROM inserted) 
		UPDATE Phone
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  Phone = @insert
END
GO
;
CREATE TRIGGER trg_ModSupplyRecord 
ON Suppliers
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT SupplierID FROM inserted) 
		UPDATE Suppliers
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  SupplierID = @insert
END
GO
;
CREATE TRIGGER trg_ModPersAddRecord 
ON PersonAddress
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT PersonID FROM inserted) 
		UPDATE PersonAddress
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  PersonID = @insert
END
GO
;
CREATE TRIGGER trg_ModEmailRecord 
ON EmailAddress
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT EmailID FROM inserted) 
		UPDATE EmailAddress
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  EmailID = @insert
END
GO
;
CREATE TRIGGER trg_ModCustRecord 
ON Customers
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT CustID FROM inserted) 
		UPDATE Customers
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  CustID = @insert
END
GO
;
CREATE TRIGGER trg_ModEmployRecord 
ON Employees
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT EmployeeID FROM inserted) 
		UPDATE Employees
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  EmployeeID = @insert
END
GO
;
CREATE TRIGGER trg_ModPubTrackRecord 
ON PubTracking
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT TrackID FROM inserted) 
		UPDATE PubTracking
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  TrackID = @insert
END
GO
;
CREATE TRIGGER trg_ModTrackDetRecord 
ON TrackingDetails
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT TrackDetailID FROM inserted) 
		UPDATE TrackingDetails
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  TrackDetailID = @insert
END
GO
;
CREATE TRIGGER trg_ModOrderRecord 
ON Orders
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT OrderID FROM inserted) 
		UPDATE Orders
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  OrderID = @insert
END
GO
;
CREATE TRIGGER trg_ModOrderDetRecord 
ON OrderDetails
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT OrderDetailID FROM inserted) 
		UPDATE OrderDetails
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  OrderDetailID = @insert
END
GO
;
CREATE TRIGGER trg_ModFeeRecord 
ON Fees
AFTER UPDATE
AS
BEGIN
	DECLARE @insert int
	SET @insert = (SELECT PubID FROM inserted) 
		UPDATE Fees
		SET ModifiedDate = GETDATE(), ModifiedBy = ORIGINAL_LOGIN()
		WHERE  FeeID = @insert
END
GO
;
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [AddressWhole];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all information on customers.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [Customers];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [DeweyDecimal];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [EmailAddress];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [Employees];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [Fees];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [LibraryCard];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [Media];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [OrderDetails];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [Orders];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [Person];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [PersonAddress];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [Phone];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [PubInventory];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [Publications];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [PubTracking];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [Suppliers];
EXECUTE sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Table containing all addresses of relevant entities.', @level0type = N'SCHEMA', @level0name = [dbo], @level1type = N'TABLE', @level1name = [TrackingDetails];
GO


insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', null, 'Tersina', null, 'Piggrem', null, '02/20/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Dr', 'Tybie', 'Peyton', 'Tolland', null, '02/12/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Dr', 'Lyndy', 'Guenna', 'Crowthe', null, '08/30/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'EM', 'Mr', 'Gertrude', null, 'Rudham', 'IV', '12/11/2014', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Dr', 'Bunni', 'Erskine', 'Dieton', null, '08/15/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Ms', 'Britt', null, 'Morgon', null, '07/31/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Mr', 'Arabella', 'Ronny', 'Gilley', null, '07/07/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Mr', 'Yul', 'Berry', 'Pownall', 'Sr', '01/20/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Ms', 'Gayla', null, 'Keppe', null, '03/08/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'EM', 'Mrs', 'Donnajean', 'Hurleigh', 'Hellard', null, '07/07/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Dr', 'Cayla', 'Willie', 'Grandham', 'Jr', '07/01/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Dr', 'Robina', 'Cal', 'Orto', null, '11/17/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Rev', 'Ramon', 'Bill', 'Eller', null, '04/09/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('AU', 'Mr', 'Ulrica', 'Buckie', 'Volker', null, '05/28/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('CU', 'Mrs', 'Karon', 'Templeton', 'Paulat', null, '11/27/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('AU', 'Honorable', 'Randa', 'Danella', 'Swale', null, '12/23/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('EM', 'Mr', 'Aldridge', null, 'Bonett', null, '10/09/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('AU', 'Ms', 'Marnie', 'Rafaellle', 'Tireman', 'Jr', '09/04/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('AU', 'Ms', 'Goran', 'Gwennie', 'McLarnon', null, '10/30/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('SC', 'Mr', 'Josephina', null, 'Jecock', 'Jr', '10/20/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Mr', 'Launce', 'Tobi', 'Flatley', null, '10/16/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Mr', 'Allene', 'Ludovika', 'Winslet', null, '12/28/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Mrs', 'Ange', 'Mollie', 'Trowell', null, '11/04/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Mr', 'Kevin', 'Raimund', 'McMylor', null, '05/29/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Mr', 'Pryce', 'Leonidas', 'Ramplee', 'IV', '07/25/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Mrs', 'Felipa', 'Elsa', 'Jopke', null, '10/05/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'EM', 'Mr', 'Charmian', null, 'Paget', 'II', '07/19/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Rev', 'Samuel', 'Sibeal', 'Triplow', 'Sr', '11/10/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Ms', 'Shannon', 'Dorey', 'Garthland', null, '01/08/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Dr', 'Ambrose', 'Nikos', 'Shreeve', null, '11/27/2014', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Ms', 'Bronson', null, 'Westmore', null, '05/08/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', null, 'Susann', null, 'Janczyk', null, '04/01/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Dr', 'Gibby', 'Ansel', 'Maly', null, '03/05/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', null, 'Josselyn', 'Flore', 'Exrol', null, '01/17/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Mr', 'Gerta', 'Vasily', 'Gracewood', null, '02/26/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Mrs', 'Vladamir', null, 'Prestland', null, '10/21/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'EM', 'Mrs', 'Kimberlyn', 'Thorvald', 'Kantor', 'III', '08/07/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'EM', 'Mr', 'Wendel', 'Rad', 'Oakenford', null, '03/20/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Rev', 'Kerrill', 'Shurlocke', 'Guierre', null, '01/08/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Rev', 'Traver', null, 'Ceney', null, '07/02/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Rev', 'Willetta', null, 'Deinhard', null, '12/26/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Mr', 'Bogey', 'Shirley', 'Donner', null, '06/02/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Mr', 'Sigmund', 'Rafael', 'Ivantsov', null, '03/01/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Dr', 'Alfred', 'Antonia', 'Brunet', null, '07/09/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', 'Rev', 'Marie-ann', 'Helaina', 'Rapa', 'III', '12/02/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', null, 'Vidovic', null, 'Tessyman', null, '09/16/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'CU', null, 'Mac', 'Joel', 'Tessyman', 'II', '11/08/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Rev', 'Marlena', null, 'Bleackly', null, '11/17/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', 'Honorable', 'Laurianne', 'Antoni', 'Jasper', 'III', '11/04/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ( 'AU', null, 'Roxane', 'Jean', 'McGuire', 'IV', '10/29/2015', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('CU', 'Mr', 'Marya', 'Nancie', 'Rau', 'IV', '09/02/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('CU', 'Ms', 'Tatiana', 'Lester', 'Joyson', null, '08/30/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('CU', 'Dr', 'Jocelin', null, 'Hickford', null, '05/27/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('CU', null, 'Ynes', null, 'Sutherington', null, '07/24/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('CU', null, 'Theda', null, 'Wilds', null, '11/22/2017', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('CU', null, 'Myrvyn', 'Ronica', 'Ellice', null, '12/16/2016', ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('CU', null, 'Crawford', 'Ailey', 'Billson', null, '10/10/2017', ORIGINAL_LOGIN());

insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('SC', 'Mr', 'Artemis', null, 'Capron', null, GETDATE(), ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('SC', 'Ms', 'Karlyn', 'Pieter', 'Magister', null, GETDATE(), ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('SC', null, 'Petunia', null, 'Godson', null, GETDATE(), ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('SC', null, 'Herrick', null, 'Southall', null, GETDATE(), ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('SC', 'Mrs', 'Ofelia', 'Ayn', 'Wegner', null, GETDATE(), ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('SC', null, 'Orion', null, 'Gresser', null, GETDATE(), ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('SC', null, 'Yance', null, 'Jolliss', null, GETDATE(), ORIGINAL_LOGIN());
insert into Person (PersonType, Title, FirstName, MidName, LastName, Suffix, ModifiedDate, ModifiedBy) values ('SC', 'Mr', 'Kingsley', null, 'Wolsey', null, GETDATE(), ORIGINAL_LOGIN());




insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '51357 Briar Crest Alley', null, 'Oklahoma City', 'Oklahoma', 'United States', '04/14/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '7153 Bluestem Street', null, 'Portland', 'Oregon', 'United States', '03/27/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '38 Kensington Parkway', null, 'Ocala', 'Florida', 'United States', '12/24/2014', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '9118 Green Ridge Parkway', null, 'Sacramento', 'California', 'United States', '03/06/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '21683 Golden Leaf Hill', null, 'Philadelphia', 'Pennsylvania', 'United States', '04/30/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '10 Barby Circle', null, 'Stockton', 'California', 'United States', '04/21/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '95 Clemons Junction', null, 'Duluth', 'Minnesota', 'United States', '01/15/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '90 Johnson Drive', null, 'Houston', 'Texas', 'United States', '01/15/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '736 American Park', null, 'Ocala', 'Florida', 'United States', '11/18/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '509 Waxwing Hill', null, 'New Orleans', 'Louisiana', 'United States', '09/09/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '6 Manitowish Avenue', null, 'Seminole', 'Florida', 'United States', '07/30/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '6 Forest Terrace', null, 'Durham', 'North Carolina', 'United States', '04/25/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '3465 Florence Court', null, 'San Antonio', 'Texas', 'United States', '08/06/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '89934 Memorial Alley', null, 'Ocala', 'Florida', 'United States', '05/11/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '1 Bartelt Plaza', 'Apt. 355', 'Pittsburgh', 'Pennsylvania', 'United States', '01/06/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '8 Chinook Pass', null, 'Houston', 'Texas', 'United States', '03/17/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '6556 Hoard Way', null, 'Flushing', 'New York', 'United States', '11/06/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '51 Anniversary Hill', 'Apt. 14', 'Louisville', 'Kentucky', 'United States', '06/30/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '5579 Hoepker Lane', null, 'Washington', 'District of Columbia', 'United States', '11/15/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '1 Artisan Center', null, 'Long Beach', 'California', 'United States', '05/24/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '59808 West Court', null, 'Mobile', 'Alabama', 'United States', '01/26/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '2794 Sundown Way', null, 'Ocala', 'Florida', 'United States', '07/09/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '59 Delaware Avenue', null, 'Yakima', 'Washington', 'United States', '03/27/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '69095 Lien Junction', null, 'Denver', 'Colorado', 'United States', '02/14/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '24346 Bultman Alley', null, 'Ashburn', 'Virginia', 'United States', '03/28/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '2502 Nevada Way', null, 'Orlando', 'Florida', 'United States', '10/26/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '3 Lien Place', null, 'Waterbury', 'Connecticut', 'United States', '01/05/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '16287 Mandrake Park', null, 'Washington', 'District of Columbia', 'United States', '04/14/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '5667 Dottie Court', 'Apt. 13C', 'Glendale', 'California', 'United States', '04/28/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '63159 Buena Vista Place', null, 'Lubbock', 'Texas', 'United States', '04/21/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '25256 Saint Paul Trail', null, 'Ocala', 'Florida', 'United States', '03/06/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '33659 Pennsylvania Hill', null, 'Ocala', 'Florida', 'United States', '03/19/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '2819 Gina Lane', null, 'Akron', 'Ohio', 'United States', '03/25/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '9693 Harper Terrace', null, 'New York City', 'New York', 'United States', '03/22/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '35354 Emmet Plaza', null, 'San Diego', 'California', 'United States', '07/28/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '4 Armistice Avenue', null, 'San Jose', 'California', 'United States', '03/28/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '68823 Westridge Drive', null, 'Monticello', 'Minnesota', 'United States', '09/03/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '3574 Coleman Street', null, 'Chicago', 'Illinois', 'United States', '12/08/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '270 Tony Plaza', null, 'Cleveland', 'Ohio', 'United States', '05/16/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '82824 Donald Road', null, 'Akron', 'Ohio', 'United States', '12/05/2015', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ( '3 Summer Ridge Way', null, 'Valley Forge', 'Pennsylvania', 'United States', '01/24/2015', ORIGINAL_LOGIN());

insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('96432 Parkside Terrace', null, 'San Diego', 'California', 'United States', '05/18/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('163 Delaware Circle', null, 'Brockton', 'Massachusetts', 'United States', '04/21/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('99 Utah Parkway', null, 'Glendale', 'Arizona', 'United States', '12/31/2016', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('7 Talmadge Parkway', null, 'Miami', 'Florida', 'United States', '01/24/2017', ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('31157 Pearson Terrace', null, 'Albuquerque', 'New Mexico', 'United States', '02/28/2017', ORIGINAL_LOGIN());

insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('39093 Scoville Terrace', null, 'Akron', 'Ohio', 'United States', GETDATE(), ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('787 Forest Run Way', null, 'Fresno', 'California', 'United States', GETDATE(), ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('04038 Lien Terrace', null, 'Las Vegas', 'Nevada', 'United States', GETDATE(), ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('74000 Grayhawk Lane', null, 'Saint Louis', 'Missouri', 'United States', GETDATE(), ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('9318 Bartelt Trail', null, 'Jacksonville', 'Florida', 'United States', GETDATE(), ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('767 Division Parkway', null, 'Memphis', 'Tennessee', 'United States', GETDATE(), ORIGINAL_LOGIN());
insert into AddressWhole (AddressLine1, AddressLine2, City, Region, Country, ModifiedDate, ModifiedBy) values ('64789 Laurel Circle', null, 'San Diego', 'California', 'United States', GETDATE(), ORIGINAL_LOGIN());

insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (1, 1, '02/20/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (2, 2, '02/12/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (4, 3, '12/11/2014', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (5, 4, '08/15/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (6, 5, '07/31/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (7, 6, '07/07/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (8, 7, '01/20/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (9, 8, '03/08/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (10, 9, '07/07/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (11, 10, '07/01/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (14, 11, '05/28/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (15, 12, '11/27/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (16, 13, '12/23/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (17, 14, '10/09/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (18, 15, '09/04/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (19, 16, '10/30/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (20, 17, '10/20/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (23, 18, '11/04/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (24, 19, '05/29/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (25, 20, '07/25/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (26, 21, '10/05/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (27, 22, '07/19/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (28, 23, '11/10/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (29, 24, '01/08/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (30, 25, '11/27/2014', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (31, 26, '05/08/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (33, 27, '03/05/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (34, 28, '01/17/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (35, 29, '02/26/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (36, 30, '10/21/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (37, 31, '08/07/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (38, 32, '03/20/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (39, 33, '01/08/2017', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (40, 34, '07/02/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (41, 35, '12/26/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (43, 36, '03/01/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (45, 37, '12/02/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (46, 38, '09/16/2015', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (48, 39, '11/17/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (49, 40, '11/04/2016', ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (50, 41, '10/29/2015', ORIGINAL_LOGIN());

insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (52, 42, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (53, 43, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (55, 44, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (57, 45, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (58, 46, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (59, 47, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (60, 48, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (61, 49, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (62, 50, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (63, 51, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (64, 52, GETDATE(), ORIGINAL_LOGIN());
insert into PersonAddress(PersonID, AddressID, ModifiedDate, ModifiedBy) values (65, 53, GETDATE(), ORIGINAL_LOGIN());

INSERT INTO Media ( Medium ) VALUES ('Book')
INSERT INTO Media ( Medium ) VALUES ('DVD')
INSERT INTO Media ( Medium ) VALUES ('Magazine')
INSERT INTO Media ( Medium ) VALUES ('Audiobook')

insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '374288741', '9/3/2021', '11/9/2016', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '373253705', '8/8/2020', '10/22/2015', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '560224907', '2/4/2019', '6/16/2015', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '504837409', '6/20/2020', '11/11/2016', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '557096065', '1/18/2018', '1/19/2016', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '677121708', '10/13/2021', '12/22/2015', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '491396062', '8/2/2018', '1/29/2016', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '305299534', '4/21/2018', '9/20/2016', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '564182081', '5/23/2018', '3/28/2017', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '542587698', '6/3/2019', '11/26/2015', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '560223073', '6/1/2020', '6/17/2015', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard (SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '354939514', '12/2/2019', '1/18/2017', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '354602841', '3/9/2019', '11/30/2016', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '560222648', '2/21/2020', '2/25/2016', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '201673900', '6/4/2019', '6/4/2016', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '675995707', '3/19/2018', '10/31/2015', GETDATE(), ORIGINAL_LOGIN());
insert into LibraryCard ( SerialNumber, ExpirationDate, SignUpDate, ModifiedDate, ModifiedBy) values ( '357263811', '4/8/2018', '9/28/2017', GETDATE(), ORIGINAL_LOGIN());

INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (4, 'grudham0@ocalib.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (5, 'bunnihill456@mgail.net', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (6, 'gorgonsflight99@coldpost.com', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (7, 'arrogill@mgail.net', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (8, 'uptheberrytree1@netcost.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (10, 'dhellard0@ocalib.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (12, 'rocal@eash.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (13, 'ram1664@netcost.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (17, 'abonett0@ocalib.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (24, 'crazzygamerr2332@mgail.net', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (25, 'the_usurper1@coldpost.com', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (27, 'cpaget0@ocalib.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (29, 'sdorey@st.chs.gov', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (30, 'ambrosesh0@jerhosp.com', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (32, 'sus316@netcost.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (34, 'johascome12@jetrain.com', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (37, 'kkantor0@ocalib.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (38, 'woaken1@fl.cpocf.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (42, 't0talb0gus@mgail.net', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (43, 'meddlersfan355@netcost.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (45, 'rapaforgod@netcost.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (46, 'roborziscool2@mgail.net', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (47, 'mactess@cookley.com', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (52, 'taitaihere@coldpost.com', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (53, 'johickf@st.rcmh.org', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (56, 'ostensibleferret1@mgail.net', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO EmailAddress (PersonID, EmailAddress, ModifiedDate, ModifiedBy) VALUES (57, 'crbill088@netcost.org', GETDATE(), ORIGINAL_LOGIN())

INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (3, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (5, 1001, 26, 2, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (6, 1001, 36, 3, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (7, 1002, 64, 4, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (8, 1002, 61, 5, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (12, 1003, 41, 7, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (13, 1004, 61, 8, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (15, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (21, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (22, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (24, 1005, 18, 10, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (25, 1006, 30, 11, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (26, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (28, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (29, 1007, 23, 13, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (30, 1008, 35, 14, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (31, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (32, 1009, 52, 15, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (33, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (34, 1010, 43, 16, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (39, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (42, 1011, 29, 19, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (43, 1011, 56, 20, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (45, 1012, 44, 21, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (46, 1013, 15, 22, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (47, 1013, 42, 23, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (51, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (52, 1014, 19, 24, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (53, 1015, 28, 25, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, ModifiedDate, ModifiedBy) VALUES (54, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (55, 1016, 13, null, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (56, 1016, 20, 26, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Customers (CustID, LibCardID, Age, EmailID, ModifiedDate, ModifiedBy) VALUES (57, 1017, 71, 27, GETDATE(), ORIGINAL_LOGIN())
;
SET IDENTITY_INSERT DeweyDecimal ON
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (000, 'Computer science, information & general works', 'Computer science, knowledge & systems', 'Computer science, information & general works')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (001, 'Computer science, information & general works','Computer science, knowledge & systems', 'Knowledge')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (002, 'Computer science, information & general works','Computer science, knowledge & systems', 'The book (writing, libraries, and book related topics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (003, 'Computer science, information & general works','Computer science, knowledge & systems', 'Systems')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (004, 'Computer science, information & general works','Computer science, knowledge & systems', 'Data processing & computer science')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (005, 'Computer science, information & general works','Computer science, knowledge & systems', 'Computer programming, programs & data')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (006, 'Computer science, information & general works','Computer science, knowledge & systems', 'Special computer methods')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (007, 'Computer science, information & general works','Computer science, knowledge & systems', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (008, 'Computer science, information & general works','Computer science, knowledge & systems', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (009, 'Computer science, information & general works','Computer science, knowledge & systems', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (010, 'Computer science, information & general works', 'Bibliographies', 'Bibliography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (011, 'Computer science, information & general works', 'Bibliographies', 'Bibliographies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (012, 'Computer science, information & general works', 'Bibliographies', 'Bibliographies of individuals')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (013, 'Computer science, information & general works', 'Bibliographies', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (014, 'Computer science, information & general works', 'Bibliographies', 'Bibliographies of anonymous & pseudonymous works')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (015, 'Computer science, information & general works', 'Bibliographies', 'Bibliographies of works from specific places')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (016, 'Computer science, information & general works', 'Bibliographies', 'Bibliographies of works on specific subjects')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (017, 'Computer science, information & general works', 'Bibliographies', 'General subject catalogs')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (018, 'Computer science, information & general works', 'Bibliographies', 'Catalogs arranged by author, date, etc.')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (019, 'Computer science, information & general works', 'Bibliographies', 'Dictionary catalogs')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (020, 'Computer science, information & general works', 'Library & information sciences', 'Library & information sciences')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (021, 'Computer science, information & general works', 'Library & information sciences', 'Library relationships (with archives, information centers, etc.)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (022, 'Computer science, information & general works', 'Library & information sciences', 'Administration of physical plant')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (023, 'Computer science, information & general works', 'Library & information sciences', 'Personnel management')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (024, 'Computer science, information & general works', 'Library & information sciences', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (025, 'Computer science, information & general works', 'Library & information sciences', 'Library operations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (026, 'Computer science, information & general works', 'Library & information sciences', 'Libraries for specific subjects')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (027, 'Computer science, information & general works', 'Library & information sciences', 'General libraries')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (028, 'Computer science, information & general works', 'Library & information sciences', 'Reading & use of other information media')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (029, 'Computer science, information & general works', 'Library & information sciences', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (030, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'General encyclopedic works')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (031, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'Encyclopedias in American English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (032, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'Encyclopedias in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (033, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'Encyclopedias in other Germanic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (034, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'Encyclopedias in French, Occitan, and Catalan')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (035, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'Encyclopedias in Italian, Romanian, and related languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (036, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'Encyclopedias in Spanish & Portuguese')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (037, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'Encyclopedias in Slavic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (038, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'Encyclopedias in Scandinavian languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (039, 'Computer science, information & general works', 'Encyclopedias & books of facts', 'Encyclopedias in other languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (040, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (041, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (042, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (043, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (044, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (045, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (046, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (047, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (048, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (049, 'Computer science, information & general works', 'Unassigned', 'Unassigned')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (050, 'Computer science, information & general works', 'Magazines, journals & serials', 'General serial publications')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (051, 'Computer science, information & general works', 'Magazines, journals & serials', 'Serials in American English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (052, 'Computer science, information & general works', 'Magazines, journals & serials', 'Serials in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (053, 'Computer science, information & general works', 'Magazines, journals & serials', 'Serials in other Germanic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (054, 'Computer science, information & general works', 'Magazines, journals & serials', 'Serials in French, Occitan, and Catalan')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (055, 'Computer science, information & general works', 'Magazines, journals & serials', 'Serials in Italian, Romanian, and related languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (056, 'Computer science, information & general works', 'Magazines, journals & serials', 'Serials in Spanish & Portuguese')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (057, 'Computer science, information & general works', 'Magazines, journals & serials', 'Serials in Slavic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (058, 'Computer science, information & general works', 'Magazines, journals & serials', 'Serials in Scandinavian languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (059, 'Computer science, information & general works', 'Magazines, journals & serials', 'Serials in other languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (060, 'Computer science, information & general works', 'Associations, organizations & museums', 'General organizations & museum science')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (061, 'Computer science, information & general works', 'Associations, organizations & museums', 'Organizations in North America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (062, 'Computer science, information & general works', 'Associations, organizations & museums', 'Organizations in British Isles; in England')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (063, 'Computer science, information & general works', 'Associations, organizations & museums', 'Organizations in central Europe; in Germany')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (064, 'Computer science, information & general works', 'Associations, organizations & museums', 'Organizations in France & Monaco')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (065, 'Computer science, information & general works', 'Associations, organizations & museums', 'Organizations in Italy & adjacent islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (066, 'Computer science, information & general works', 'Associations, organizations & museums', 'Organizations in Iberian peninsula & adjacent islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (067, 'Computer science, information & general works', 'Associations, organizations & museums', 'Organizations in eastern Europe; in Russia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (068, 'Computer science, information & general works', 'Associations, organizations & museums', 'Organizations in other geographic areas')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (069, 'Computer science, information & general works', 'Associations, organizations & museums', 'Museum science')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (070, 'Computer science, information & general works', 'News media, journalism & publishing', 'News media, journalism, and publishing')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (071, 'Computer science, information & general works', 'News media, journalism & publishing', 'Newspapers in North America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (072, 'Computer science, information & general works', 'News media, journalism & publishing', 'Newspapers in British Isles; in England')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (073, 'Computer science, information & general works', 'News media, journalism & publishing', 'Newspapers in central Europe; in Germany')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (074, 'Computer science, information & general works', 'News media, journalism & publishing', 'Newspapers in France & Monaco')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (075, 'Computer science, information & general works', 'News media, journalism & publishing', 'Newspapers in Italy & adjacent islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (076, 'Computer science, information & general works', 'News media, journalism & publishing', 'Newspapers in Iberian peninsula & adjacent islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (077, 'Computer science, information & general works', 'News media, journalism & publishing', 'Newspapers in eastern Europe; in Russia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (078, 'Computer science, information & general works', 'News media, journalism & publishing', 'Newspapers in Scandinavia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (079, 'Computer science, information & general works', 'News media, journalism & publishing', 'Newspapers in other geographic areas')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (080, 'Computer science, information & general works', 'Quotations', 'General collections')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (081, 'Computer science, information & general works', 'Quotations', 'Collections in American English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (082, 'Computer science, information & general works', 'Quotations', 'Collections in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (083, 'Computer science, information & general works', 'Quotations', 'Collections in other Germanic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (084, 'Computer science, information & general works', 'Quotations', 'Collections in French, Occitan, Catalan')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (085, 'Computer science, information & general works', 'Quotations', 'Collections in Italian, Romanian, & related languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (086, 'Computer science, information & general works', 'Quotations', 'Collections in Spanish & Portuguese')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (087, 'Computer science, information & general works', 'Quotations', 'Collections in Slavic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (088, 'Computer science, information & general works', 'Quotations', 'Collections in Scandinavian languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (089, 'Computer science, information & general works', 'Quotations', 'Collections in other languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (090, 'Computer science, information & general works', 'Manuscripts & rare books', 'Manuscripts and rare books')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (091, 'Computer science, information & general works', 'Manuscripts & rare books', 'Manuscripts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (092, 'Computer science, information & general works', 'Manuscripts & rare books', 'Block books')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (093, 'Computer science, information & general works', 'Manuscripts & rare books', 'Incunabula')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (094, 'Computer science, information & general works', 'Manuscripts & rare books', 'Printed books')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (095, 'Computer science, information & general works', 'Manuscripts & rare books', 'Books notable for bindings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (096, 'Computer science, information & general works', 'Manuscripts & rare books', 'Books notable for illustrations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (097, 'Computer science, information & general works', 'Manuscripts & rare books', 'Books notable for ownership or origin')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (098, 'Computer science, information & general works', 'Manuscripts & rare books', 'Prohibited works, forgeries, and hoaxes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (099, 'Computer science, information & general works', 'Manuscripts & rare books', 'Books notable for format')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (100, 'Philosophy & psychology', 'Philosophy', 'Philosophy & psychology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (101, 'Philosophy & psychology', 'Philosophy', 'Theory of philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (102, 'Philosophy & psychology', 'Philosophy', 'Miscellany')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (103, 'Philosophy & psychology', 'Philosophy', 'Dictionaries & encyclopedias')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (104, 'Philosophy & psychology', 'Philosophy', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (105, 'Philosophy & psychology', 'Philosophy', 'Serial publications')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (106, 'Philosophy & psychology', 'Philosophy', 'Organizations & management')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (107, 'Philosophy & psychology', 'Philosophy', 'Education, research, related topics of philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (108, 'Philosophy & psychology', 'Philosophy', 'Groups of people')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (109, 'Philosophy & psychology', 'Philosophy', 'History & collected biography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (110, 'Philosophy & psychology', 'Metaphysics', 'Metaphysics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (111, 'Philosophy & psychology', 'Metaphysics', 'Ontology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (112, 'Philosophy & psychology', 'Metaphysics', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (113, 'Philosophy & psychology', 'Metaphysics', 'Cosmology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (114, 'Philosophy & psychology', 'Metaphysics', 'Space')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (115, 'Philosophy & psychology', 'Metaphysics', 'Time')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (116, 'Philosophy & psychology', 'Metaphysics', 'Change')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (117, 'Philosophy & psychology', 'Metaphysics', 'Structure')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (118, 'Philosophy & psychology', 'Metaphysics', 'Force and energy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (119, 'Philosophy & psychology', 'Metaphysics', 'Number and quantity')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (120, 'Philosophy & psychology', 'Epistemology', 'Epistemology, causation, and humankind')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (121, 'Philosophy & psychology', 'Epistemology', 'Epistemology (Theory of knowledge)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (122, 'Philosophy & psychology', 'Epistemology', 'Causation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (123, 'Philosophy & psychology', 'Epistemology', 'Determinism and indeterminism')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (124, 'Philosophy & psychology', 'Epistemology', 'Teleology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (125, 'Philosophy & psychology', 'Epistemology', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (126, 'Philosophy & psychology', 'Epistemology', 'The self')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (127, 'Philosophy & psychology', 'Epistemology', 'The unconscious & the subconscious')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (128, 'Philosophy & psychology', 'Epistemology', 'Humankind')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (129, 'Philosophy & psychology', 'Epistemology', 'Origin & destiny of individual souls')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (130, 'Philosophy & psychology', 'Parapsychology & occultism', 'Parapsychology & occultism')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (131, 'Philosophy & psychology', 'Parapsychology & occultism', 'Parapsychological and occult methods for achieving well-being, happiness, success')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (132, 'Philosophy & psychology', 'Parapsychology & occultism', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (133, 'Philosophy & psychology', 'Parapsychology & occultism', 'Specific topics in parapsychology & occultism')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (134, 'Philosophy & psychology', 'Parapsychology & occultism', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (135, 'Philosophy & psychology', 'Parapsychology & occultism', 'Dreams & mysteries')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (136, 'Philosophy & psychology', 'Parapsychology & occultism', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (137, 'Philosophy & psychology', 'Parapsychology & occultism', 'Divinatory graphology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (138, 'Philosophy & psychology', 'Parapsychology & occultism', 'Physiognomy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (139, 'Philosophy & psychology', 'Parapsychology & occultism', 'Phrenology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (140, 'Philosophy & psychology', 'Philosophical schools of thought', 'Specific philosophical schools and viewpoints')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (141, 'Philosophy & psychology', 'Philosophical schools of thought', 'Idealism & related systems & doctrines')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (142, 'Philosophy & psychology', 'Philosophical schools of thought', 'Critical philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (143, 'Philosophy & psychology', 'Philosophical schools of thought', 'Bergsonism & intuitionism')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (144, 'Philosophy & psychology', 'Philosophical schools of thought', 'Humanism & related systems & doctrines')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (145, 'Philosophy & psychology', 'Philosophical schools of thought', 'Sensationalism')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (146, 'Philosophy & psychology', 'Philosophical schools of thought', 'Naturalism & related systems & doctrines')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (147, 'Philosophy & psychology', 'Philosophical schools of thought', 'Pantheism & related systems & doctrines')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (148, 'Philosophy & psychology', 'Philosophical schools of thought', 'Dogmatism, eclecticism, liberalism, syncretism, & traditionalism')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (149, 'Philosophy & psychology', 'Philosophical schools of thought', 'Other philosophical systems & doctrines')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (150, 'Philosophy & psychology', 'Psychology', 'Psychology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (151, 'Philosophy & psychology', 'Psychology', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (152, 'Philosophy & psychology', 'Psychology', 'Sensory perception, movement, emotions, & physiological drives')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (153, 'Philosophy & psychology', 'Psychology', 'Conscious mental processes & intelligence')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (154, 'Philosophy & psychology', 'Psychology', 'Subconscious & altered states & processes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (155, 'Philosophy & psychology', 'Psychology', 'Differential & developmental psychology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (156, 'Philosophy & psychology', 'Psychology', 'Comparative psychology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (157, 'Philosophy & psychology', 'Psychology', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (158, 'Philosophy & psychology', 'Psychology', 'Applied psychology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (159, 'Philosophy & psychology', 'Psychology', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (160, 'Philosophy & psychology', 'Philosophical logic', 'Philosophical logic')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (161, 'Philosophy & psychology', 'Philosophical logic', 'Induction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (162, 'Philosophy & psychology', 'Philosophical logic', 'Deduction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (163, 'Philosophy & psychology', 'Philosophical logic', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (164, 'Philosophy & psychology', 'Philosophical logic', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (165, 'Philosophy & psychology', 'Philosophical logic', 'Fallacies & sources of error')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (166, 'Philosophy & psychology', 'Philosophical logic', 'Syllogisms')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (167, 'Philosophy & psychology', 'Philosophical logic', 'Hypotheses')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (168, 'Philosophy & psychology', 'Philosophical logic', 'Argument & persuasion')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (169, 'Philosophy & psychology', 'Philosophical logic', 'Analogy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (170, 'Philosophy & psychology', 'Ethics', 'Ethics (Moral philosophy)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (171, 'Philosophy & psychology', 'Ethics', 'Ethical systems')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (172, 'Philosophy & psychology', 'Ethics', 'Political ethics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (173, 'Philosophy & psychology', 'Ethics', 'Ethics of family relationships')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (174, 'Philosophy & psychology', 'Ethics', 'Occupational ethics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (175, 'Philosophy & psychology', 'Ethics', 'Ethics of recreation, leisure, public performances, communication')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (176, 'Philosophy & psychology', 'Ethics', 'Ethics of sex & reproduction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (177, 'Philosophy & psychology', 'Ethics', 'Ethics of social relations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (178, 'Philosophy & psychology', 'Ethics', 'Ethics of consumption')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (179, 'Philosophy & psychology', 'Ethics', 'Other ethical norms')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (180, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Ancient, Medieval, Eastern philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (181, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Eastern philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (182, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Pre-Socratic Greek philosophies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (183, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Sophistic, Socratic, related Greek philosophies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (184, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Platonic philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (185, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Aristotelian philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (186, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Skeptic & Neoplatonic philosophies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (187, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Epicurean philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (188, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Stoic philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (189, 'Philosophy & psychology', 'Ancient, Medieval, & Eastern philosophy', 'Medieval Western philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (190, 'Philosophy & psychology', 'Modern Western philosophy', 'Modern Western & other Non-Eastern philosophy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (191, 'Philosophy & psychology', 'Modern Western philosophy', 'Philosophy of the United States and Canada')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (192, 'Philosophy & psychology', 'Modern Western philosophy', 'Philosophy of the British Isles')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (193, 'Philosophy & psychology', 'Modern Western philosophy', 'Philosophy of Germany and Austria')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (194, 'Philosophy & psychology', 'Modern Western philosophy', 'Philosophy of France')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (195, 'Philosophy & psychology', 'Modern Western philosophy', 'Philosophy of Italy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (196, 'Philosophy & psychology', 'Modern Western philosophy', 'Philosophy of Spain and Portugal')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (197, 'Philosophy & psychology', 'Modern Western philosophy', 'Philosophy of Russia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (198, 'Philosophy & psychology', 'Modern Western philosophy', 'Philosophy of Scandinavia & Finland')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (199, 'Philosophy & psychology', 'Modern Western philosophy', 'Philosophy in other geographic areas')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (200, 'Religion', 'Religion', 'Religion')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (201, 'Religion', 'Religion', 'Religious mythology, general classes of religion, interreligious relations and attitudes, social theology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (202, 'Religion', 'Religion', 'Doctrines')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (203, 'Religion', 'Religion', 'Public worship and other practices')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (204, 'Religion', 'Religion', 'Religious experience, life, practice')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (205, 'Religion', 'Religion', 'Religious ethics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (206, 'Religion', 'Religion', 'Leaders and organization')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (207, 'Religion', 'Religion', 'Missions and religious education')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (208, 'Religion', 'Religion', 'Sources')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (209, 'Religion', 'Religion', 'Sects and reform movements')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (210, 'Religion', 'Philosophy & theory of religion', 'Philosophy & theory of religion')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (211, 'Religion', 'Philosophy & theory of religion', 'Concepts of God')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (212, 'Religion', 'Philosophy & theory of religion', 'Existence, ways of knowing God, attributes of God')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (213, 'Religion', 'Philosophy & theory of religion', 'Creation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (214, 'Religion', 'Philosophy & theory of religion', 'Theodicy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (215, 'Religion', 'Philosophy & theory of religion', 'Science & religion')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (216, 'Religion', 'Philosophy & theory of religion', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (217, 'Religion', 'Philosophy & theory of religion', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (218, 'Religion', 'Philosophy & theory of religion', 'Humankind')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (219, 'Religion', 'Philosophy & theory of religion', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (220, 'Religion', 'The Bible', 'Bible')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (221, 'Religion', 'The Bible', 'Old Testament (Tanakh)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (222, 'Religion', 'The Bible', 'Historical books of Old Testament')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (223, 'Religion', 'The Bible', 'Poetic books of Old Testament')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (224, 'Religion', 'The Bible', 'Prophetic books of Old Testament')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (225, 'Religion', 'The Bible', 'New Testament')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (226, 'Religion', 'The Bible', 'Gospels & Acts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (227, 'Religion', 'The Bible', 'Epistles')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (228, 'Religion', 'The Bible', 'Revelation (Apocalypse)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (229, 'Religion', 'The Bible', 'Apocrypha, pseudepigrapha, & intertestamental works')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (230, 'Religion', 'Christianity', 'Christianity')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (231, 'Religion', 'Christianity', 'God')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (232, 'Religion', 'Christianity', 'Jesus Christ & his family')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (233, 'Religion', 'Christianity', 'Humankind')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (234, 'Religion', 'Christianity', 'Salvation & grace')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (235, 'Religion', 'Christianity', 'Spiritual beings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (236, 'Religion', 'Christianity', 'Eschatology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (237, 'Religion', 'Christianity', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (238, 'Religion', 'Christianity', 'Creeds, confessions of faith, covenants, & catechisms')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (239, 'Religion', 'Christianity', 'Apologetics & polemics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (240, 'Religion', 'Christian practice & observance', 'Christian moral and devotional theology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (241, 'Religion', 'Christian practice & observance', 'Christian ethics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (242, 'Religion', 'Christian practice & observance', 'Devotional literature')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (243, 'Religion', 'Christian practice & observance', 'Evangelistic writings for individuals and families')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (244, 'Religion', 'Christian practice & observance', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (245, 'Religion', 'Christian practice & observance', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (246, 'Religion', 'Christian practice & observance', 'Use of art in Christianity')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (247, 'Religion', 'Christian practice & observance', 'Church furnishings & related articles')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (248, 'Religion', 'Christian practice & observance', 'Christian experience, practice, life')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (249, 'Religion', 'Christian practice & observance', 'Christian observances in family life')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (250, 'Religion', 'Christian orders & local church', 'Local Christian church and Christian religious orders')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (251, 'Religion', 'Christian orders & local church', 'Preaching (Homiletics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (252, 'Religion', 'Christian orders & local church', 'Texts of sermons')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (253, 'Religion', 'Christian orders & local church', 'Pastoral office and work (Pastoral theology)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (254, 'Religion', 'Christian orders & local church', 'Parish administration')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (255, 'Religion', 'Christian orders & local church', 'Religious congregations & orders')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (256, 'Religion', 'Christian orders & local church', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (257, 'Religion', 'Christian orders & local church', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (258, 'Religion', 'Christian orders & local church', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (259, 'Religion', 'Christian orders & local church', 'Pastoral care of families, of specific groups of people')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (260, 'Religion', 'Social & ecclesiastical theology', 'Christian social and ecclesiastical theology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (261, 'Religion', 'Social & ecclesiastical theology', 'Social theology and interreligious relations and attitudes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (262, 'Religion', 'Social & ecclesiastical theology', 'Ecclesiology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (263, 'Religion', 'Social & ecclesiastical theology', 'Days, times, places of religious observance')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (264, 'Religion', 'Social & ecclesiastical theology', 'Public worship')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (265, 'Religion', 'Social & ecclesiastical theology', 'Sacraments, other rites & acts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (266, 'Religion', 'Social & ecclesiastical theology', 'Missions')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (267, 'Religion', 'Social & ecclesiastical theology', 'Associations for religious work')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (268, 'Religion', 'Social & ecclesiastical theology', 'Religious education')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (269, 'Religion', 'Social & ecclesiastical theology', 'Spiritual renewal')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (270, 'Religion', 'History of Christianity', 'History, geographic treatment, biography of Christianity')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (271, 'Religion', 'History of Christianity', 'Religious congregations and orders in church history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (272, 'Religion', 'History of Christianity', 'Persecutions in church history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (273, 'Religion', 'History of Christianity', 'Doctrinal controversies and heresies in general church history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (274, 'Religion', 'History of Christianity', 'Christianity in Europe')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (275, 'Religion', 'History of Christianity', 'Christianity in Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (276, 'Religion', 'History of Christianity', 'Christianity in Africa')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (277, 'Religion', 'History of Christianity', 'Christianity in North America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (278, 'Religion', 'History of Christianity', 'Christianity in South America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (279, 'Religion', 'History of Christianity', 'History of Christianity in other areas')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (280, 'Religion', 'Christian denominations', 'Denominations and sects of Christian church')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (281, 'Religion', 'Christian denominations', 'Early church & Eastern churches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (282, 'Religion', 'Christian denominations', 'Roman Catholic Church')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (283, 'Religion', 'Christian denominations', 'Anglican churches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (284, 'Religion', 'Christian denominations', 'Protestant denominations of Continental origin & related body')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (285, 'Religion', 'Christian denominations', 'Presbyterian churches, Reformed churches centered in America, Congregational churches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (286, 'Religion', 'Christian denominations', 'Baptist, Restoration Movement, Adventist churches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (287, 'Religion', 'Christian denominations', 'Methodist churches; churches related to Methodism')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (288, 'Religion', 'Christian denominations', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (289, 'Religion', 'Christian denominations', 'Other denominations & sects')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (290, 'Religion', 'Other religions', 'Other religions')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (291, 'Religion', 'Other religions', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (292, 'Religion', 'Other religions', 'Classical religion (Greek & Roman religion)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (293, 'Religion', 'Other religions', 'Germanic religion')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (294, 'Religion', 'Other religions', 'Religions of Indic origin')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (295, 'Religion', 'Other religions', 'Zoroastrianism (Mazdaism, Parseeism)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (296, 'Religion', 'Other religions', 'Judaism')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (297, 'Religion', 'Other religions', 'Islam, Bábism & Baháí Faith')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (298, 'Religion', 'Other religions', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (299, 'Religion', 'Other religions', 'Religions not provided for elsewhere')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (300, 'Social sciences', 'Social sciences, sociology & anthropology', 'Social sciences')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (301, 'Social sciences', 'Social sciences, sociology & anthropology', 'Sociology & anthropology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (302, 'Social sciences', 'Social sciences, sociology & anthropology', 'Social interaction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (303, 'Social sciences', 'Social sciences, sociology & anthropology', 'Social processes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (304, 'Social sciences', 'Social sciences, sociology & anthropology', 'Factors affecting social behavior')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (305, 'Social sciences', 'Social sciences, sociology & anthropology', 'Groups of people')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (306, 'Social sciences', 'Social sciences, sociology & anthropology', 'Culture & institutions')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (307, 'Social sciences', 'Social sciences, sociology & anthropology', 'Communities')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (308, 'Social sciences', 'Social sciences, sociology & anthropology', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (309, 'Social sciences', 'Social sciences, sociology & anthropology', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (310, 'Social sciences', 'Statistics', 'Collections of general statistics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (311, 'Social sciences', 'Statistics', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (312, 'Social sciences', 'Statistics', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (313, 'Social sciences', 'Statistics', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (314, 'Social sciences', 'Statistics', 'General statistics of Europe')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (315, 'Social sciences', 'Statistics', 'General statistics of Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (316, 'Social sciences', 'Statistics', 'General statistics of Africa')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (317, 'Social sciences', 'Statistics', 'General statistics of North America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (318, 'Social sciences', 'Statistics', 'General statistics of South America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (319, 'Social sciences', 'Statistics', 'General statistics of Australasia, Pacific Ocean islands, Atlantic Ocean islands, Arctic islands, Antarctica')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (320, 'Social sciences', 'Political science', 'Political science (Politics & government)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (321, 'Social sciences', 'Political science', 'Systems of governments & states')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (322, 'Social sciences', 'Political science', 'Relation of state to organized groups & their members')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (323, 'Social sciences', 'Political science', 'Civil & political rights')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (324, 'Social sciences', 'Political science', 'The political process')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (325, 'Social sciences', 'Political science', 'International migration & colonization')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (326, 'Social sciences', 'Political science', 'Slavery & emancipation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (327, 'Social sciences', 'Political science', 'International relations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (328, 'Social sciences', 'Political science', 'The legislative process')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (329, 'Social sciences', 'Political science', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (330, 'Social sciences', 'Economics', 'Economics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (331, 'Social sciences', 'Economics', 'Labor economics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (332, 'Social sciences', 'Economics', 'Financial economics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (333, 'Social sciences', 'Economics', 'Economics of land & energy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (334, 'Social sciences', 'Economics', 'Cooperatives')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (335, 'Social sciences', 'Economics', 'Socialism & related systems')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (336, 'Social sciences', 'Economics', 'Public finance')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (337, 'Social sciences', 'Economics', 'International economics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (338, 'Social sciences', 'Economics', 'Production')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (339, 'Social sciences', 'Economics', 'Macroeconomics & related topics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (340, 'Social sciences', 'Law', 'Law')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (341, 'Social sciences', 'Law', 'Law of nations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (342, 'Social sciences', 'Law', 'Constitutional & administrative law')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (343, 'Social sciences', 'Law', 'Military, defense, public property, public finance, tax, commerce (trade), industrial law')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (344, 'Social sciences', 'Law', 'Labor, social service, education, cultural law')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (345, 'Social sciences', 'Law', 'Criminal law')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (346, 'Social sciences', 'Law', 'Private law')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (347, 'Social sciences', 'Law', 'Procedure & courts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (348, 'Social sciences', 'Law', 'Laws, regulations, cases')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (349, 'Social sciences', 'Law', 'Law of specific jurisdictions, areas, socioeconomic regions, regional intergovernmental organizations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (350, 'Social sciences', 'Public administration & military science', 'Public administration & military science')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (351, 'Social sciences', 'Public administration & military science', 'Public administration')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (352, 'Social sciences', 'Public administration & military science', 'General considerations of public administration')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (353, 'Social sciences', 'Public administration & military science', 'Specific fields of public administration')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (354, 'Social sciences', 'Public administration & military science', 'Public administration of economy & environment')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (355, 'Social sciences', 'Public administration & military science', 'Military science')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (356, 'Social sciences', 'Public administration & military science', 'Foot forces & warfare')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (357, 'Social sciences', 'Public administration & military science', 'Mounted forces & warfare')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (358, 'Social sciences', 'Public administration & military science', 'Air & other specialized forces & warfare; engineering & related services')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (359, 'Social sciences', 'Public administration & military science', 'Sea forces & warfare')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (360, 'Social sciences', 'Social problems & social services', 'Social problems & services; associations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (361, 'Social sciences', 'Social problems & social services', 'Social problems & services')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (362, 'Social sciences', 'Social problems & social services', 'Social problems of & services to groups of people')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (363, 'Social sciences', 'Social problems & social services', 'Other social problems & services')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (364, 'Social sciences', 'Social problems & social services', 'Criminology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (365, 'Social sciences', 'Social problems & social services', 'Penal & related institutions')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (366, 'Social sciences', 'Social problems & social services', 'Secret associations & societies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (367, 'Social sciences', 'Social problems & social services', 'General clubs')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (368, 'Social sciences', 'Social problems & social services', 'Insurance')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (369, 'Social sciences', 'Social problems & social services', 'Associations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (370, 'Social sciences', 'Education', 'Education')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (371, 'Social sciences', 'Education', 'Schools & their activities; special education')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (372, 'Social sciences', 'Education', 'Primary education (Elementary education)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (373, 'Social sciences', 'Education', 'Secondary education')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (374, 'Social sciences', 'Education', 'Adult education')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (375, 'Social sciences', 'Education', 'Curricula')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (376, 'Social sciences', 'Education', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (377, 'Social sciences', 'Education', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (378, 'Social sciences', 'Education', 'Higher education (Tertiary education)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (379, 'Social sciences', 'Education', 'Public policy issues in education')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (380, 'Social sciences', 'Commerce, communications, & transportation', 'Commerce, communications, transportation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (381, 'Social sciences', 'Commerce, communications, & transportation', 'Commerce (Trade)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (382, 'Social sciences', 'Commerce, communications, & transportation', 'International commerce (Foreign trade)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (383, 'Social sciences', 'Commerce, communications, & transportation', 'Postal communication')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (384, 'Social sciences', 'Commerce, communications, & transportation', 'Communications')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (385, 'Social sciences', 'Commerce, communications, & transportation', 'Railroad transportation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (386, 'Social sciences', 'Commerce, communications, & transportation', 'Inland waterway & ferry transportation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (387, 'Social sciences', 'Commerce, communications, & transportation', 'Water, air, space transportation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (388, 'Social sciences', 'Commerce, communications, & transportation', 'Transportation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (389, 'Social sciences', 'Commerce, communications, & transportation', 'Metrology & standardization')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (390, 'Social sciences', 'Customs, etiquette, & folklore', 'Customs, etiquette, folklore')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (391, 'Social sciences', 'Customs, etiquette, & folklore', 'Costume & personal appearance')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (392, 'Social sciences', 'Customs, etiquette, & folklore', 'Customs of life cycle & domestic life')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (393, 'Social sciences', 'Customs, etiquette, & folklore', 'Death customs')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (394, 'Social sciences', 'Customs, etiquette, & folklore', 'General customs')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (395, 'Social sciences', 'Customs, etiquette, & folklore', 'Etiquette (Manners)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (396, 'Social sciences', 'Customs, etiquette, & folklore', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (397, 'Social sciences', 'Customs, etiquette, & folklore', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (398, 'Social sciences', 'Customs, etiquette, & folklore', 'Folklore')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (399, 'Social sciences', 'Customs, etiquette, & folklore', 'Customs of war & diplomacy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (400, 'Language', 'Language', 'Language')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (401, 'Language', 'Language', 'Philosophy & theory; international languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (402, 'Language', 'Language', 'Miscellany')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (403, 'Language', 'Language', 'Dictionaries, encyclopedias, concordances')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (404, 'Language', 'Language', 'Special topics of language')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (405, 'Language', 'Language', 'Serial publications')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (406, 'Language', 'Language', 'Organizations & management')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (407, 'Language', 'Language', 'Education, research, related topics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (408, 'Language', 'Language', 'Groups of people')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (409, 'Language', 'Language', 'Geographic treatment & biography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (410, 'Language', 'Linguistics', 'Linguistics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (411, 'Language', 'Linguistics', 'Writing systems of standard forms of languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (412, 'Language', 'Linguistics', 'Etymology of standard forms of languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (413, 'Language', 'Linguistics', 'Dictionaries of standard forms of languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (414, 'Language', 'Linguistics', 'Phonology & phonetics of standard forms of languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (415, 'Language', 'Linguistics', 'Grammar of standard forms of languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (416, 'Language', 'Linguistics', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (417, 'Language', 'Linguistics', 'Dialectology & historical linguistics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (418, 'Language', 'Linguistics', 'Standard usage (Prescriptive linguistics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (419, 'Language', 'Linguistics', 'Sign languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (420, 'Language', 'English & Old English languages', 'English & Old English (Anglo-Saxon)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (421, 'Language', 'English & Old English languages', 'Writing system, phonology, phonetics of standard English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (422, 'Language', 'English & Old English languages', 'Etymology of standard English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (423, 'Language', 'English & Old English languages', 'Dictionaries of standard English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (424, 'Language', 'English & Old English languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (425, 'Language', 'English & Old English languages', 'Grammar of standard English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (426, 'Language', 'English & Old English languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (427, 'Language', 'English & Old English languages', 'Historical & geographical variations, modern nongeographic variations of English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (428, 'Language', 'English & Old English languages', 'Standard English usage (Prescriptive linguistics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (429, 'Language', 'English & Old English languages', 'Old English (Anglo-Saxon)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (430, 'Language', 'German & related languages', 'German and related languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (431, 'Language', 'German & related languages', 'Writing systems, phonology, phonetics of standard German')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (432, 'Language', 'German & related languages', 'Etymology of standard German')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (433, 'Language', 'German & related languages', 'Dictionaries of standard German')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (434, 'Language', 'German & related languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (435, 'Language', 'German & related languages', 'Grammar of standard German')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (436, 'Language', 'German & related languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (437, 'Language', 'German & related languages', 'Historical & geographic variations, modern nongeographic variations of German')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (438, 'Language', 'German & related languages', 'Standard German usage (Prescriptive linguistics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (439, 'Language', 'German & related languages', 'Other Germanic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (440, 'Language', 'French & related languages', 'French & related Romance languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (441, 'Language', 'French & related languages', 'Writing systems, phonology, phonetics of standard French')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (442, 'Language', 'French & related languages', 'Etymology of standard French')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (443, 'Language', 'French & related languages', 'Dictionaries of standard French')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (444, 'Language', 'French & related languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (445, 'Language', 'French & related languages', 'Grammar of standard French')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (446, 'Language', 'French & related languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (447, 'Language', 'French & related languages', 'Historical and geographic variations, modern nongeographic variations of French')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (448, 'Language', 'French & related languages', 'Standard French usage (Prescriptive linguistics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (449, 'Language', 'French & related languages', 'Occitan Catalan, Franco-Provençal')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (450, 'Language', 'Italian, Romanian, & related languages', 'Italian, Dalmatian, Romanian, Rhaetian, Sardinian, Corsican')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (451, 'Language', 'Italian, Romanian, & related languages', 'Writing systems, phonology, phonetics of standard Italian')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (452, 'Language', 'Italian, Romanian, & related languages', 'Etymology of standard Italian')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (453, 'Language', 'Italian, Romanian, & related languages', 'Dictionaries of standard Italian')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (454, 'Language', 'Italian, Romanian, & related languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (455, 'Language', 'Italian, Romanian, & related languages', 'Grammar of standard Italian')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (456, 'Language', 'Italian, Romanian, & related languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (457, 'Language', 'Italian, Romanian, & related languages', 'Historical & geographic variations, modern nongeographic variations of Italian')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (458, 'Language', 'Italian, Romanian, & related languages', 'Standard Italian usage (Prescriptive linguistics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (459, 'Language', 'Italian, Romanian, & related languages', 'Romanian, Rhaetian, Sardinian, Corsican')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (460, 'Language', 'Spanish, Portuguese, Galician', 'Spanish, Portuguese, Galician')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (461, 'Language', 'Spanish, Portuguese, Galician', 'Writing systems, phonology, phonetics of standard Spanish')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (462, 'Language', 'Spanish, Portuguese, Galician', 'Etymology of standard Spanish')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (463, 'Language', 'Spanish, Portuguese, Galician', 'Dictionaries of standard Spanish')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (464, 'Language', 'Spanish, Portuguese, Galician', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (465, 'Language', 'Spanish, Portuguese, Galician', 'Grammar of standard Spanish')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (466, 'Language', 'Spanish, Portuguese, Galician', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (467, 'Language', 'Spanish, Portuguese, Galician', 'Historical & geographic variations, modern nongeographic variations of Spanish')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (468, 'Language', 'Spanish, Portuguese, Galician', 'Standard Spanish usage (Prescriptive linguistics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (469, 'Language', 'Spanish, Portuguese, Galician', 'Portuguese')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (470, 'Language', 'Latin & Italic languages', 'Latin & related Italic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (471, 'Language', 'Latin & Italic languages', 'Writing systems, phonology, phonetics of classical Latin')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (472, 'Language', 'Latin & Italic languages', 'Etymology of classical Latin')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (473, 'Language', 'Latin & Italic languages', 'Dictionaries of classical Latin')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (474, 'Language', 'Latin & Italic languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (475, 'Language', 'Latin & Italic languages', 'Grammar of classical Latin')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (476, 'Language', 'Latin & Italic languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (477, 'Language', 'Latin & Italic languages', 'Old, postclassical, Vulgar Latin')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (478, 'Language', 'Latin & Italic languages', 'Classical Latin usage (Prescriptive linguistics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (479, 'Language', 'Latin & Italic languages', 'Other Italic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (480, 'Language', 'Classical & modern Greek languages', 'Classical Greek & related Hellenic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (481, 'Language', 'Classical & modern Greek languages', 'Writing systems, phonology, phonetics of classical Greek')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (482, 'Language', 'Classical & modern Greek languages', 'Etymology of classical Greek')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (483, 'Language', 'Classical & modern Greek languages', 'Dictionaries of classical Greek')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (484, 'Language', 'Classical & modern Greek languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (485, 'Language', 'Classical & modern Greek languages', 'Grammar of classical Greek')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (486, 'Language', 'Classical & modern Greek languages', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (487, 'Language', 'Classical & modern Greek languages', 'Preclassical & postclassical Greek')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (488, 'Language', 'Classical & modern Greek languages', 'Classical Greek usage (Prescriptive linguistics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (489, 'Language', 'Classical & modern Greek languages', 'Other Hellenic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (490, 'Language', 'Other languages', 'Other languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (491, 'Language', 'Other languages', 'East Indo-European & Celtic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (492, 'Language', 'Other languages', 'Afro-Asiatic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (493, 'Language', 'Other languages', 'Non-Semitic Afro-Asiatic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (494, 'Language', 'Other languages', 'Altic, Uralic, Hyperborean, Dravidian languages, miscellaneous languages of south Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (495, 'Language', 'Other languages', 'Languages of East & Southeast Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (496, 'Language', 'Other languages', 'African languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (497, 'Language', 'Other languages', 'North American native languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (498, 'Language', 'Other languages', 'South American native languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (499, 'Language', 'Other languages', 'Non-Austronesian languages of Oceania, Austronesian languages, miscellaneous languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (500, 'Science', 'Science', 'Natural sciences & mathematics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (501, 'Science', 'Science', 'Philosophy & theory')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (502, 'Science', 'Science', 'Miscellany')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (503, 'Science', 'Science', 'Dictionaries, encyclopedias, concordances')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (504, 'Science', 'Science', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (505, 'Science', 'Science', 'Serial publications')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (506, 'Science', 'Science', 'Organizations & management')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (507, 'Science', 'Science', 'Education, research, related topics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (508, 'Science', 'Science', 'Natural history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (509, 'Science', 'Science', 'History, geographic treatment, biography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (510, 'Science', 'Mathematics', 'Mathematics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (511, 'Science', 'Mathematics', 'General principles of mathematics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (512, 'Science', 'Mathematics', 'Algebra')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (513, 'Science', 'Mathematics', 'Arithmetic')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (514, 'Science', 'Mathematics', 'Topology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (515, 'Science', 'Mathematics', 'Analysis')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (516, 'Science', 'Mathematics', 'Geometry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (517, 'Science', 'Mathematics', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (518, 'Science', 'Mathematics', 'Numerical analysis')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (519, 'Science', 'Mathematics', 'Probabilities & applied mathematics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (520, 'Science', 'Astronomy', 'Astronomy & allied sciences')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (521, 'Science', 'Astronomy', 'Celestial mechanics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (522, 'Science', 'Astronomy', 'Techniques, procedures, apparatus, equipment, materials')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (523, 'Science', 'Astronomy', 'Specific celestial bodies & phenomena')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (524, 'Science', 'Astronomy', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (525, 'Science', 'Astronomy', 'Earth (Astronomical geography)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (526, 'Science', 'Astronomy', 'Mathematical geography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (527, 'Science', 'Astronomy', 'Celestial navigation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (528, 'Science', 'Astronomy', 'Ephemerides')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (529, 'Science', 'Astronomy', 'Chronology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (530, 'Science', 'Physics', 'Physics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (531, 'Science', 'Physics', 'Classical mechanics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (532, 'Science', 'Physics', 'Fluid mechanics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (533, 'Science', 'Physics', 'Pneumatics (Gas mechanics)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (534, 'Science', 'Physics', 'Sound & related vibrations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (535, 'Science', 'Physics', 'Light & related radiation')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (536, 'Science', 'Physics', 'Heat')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (537, 'Science', 'Physics', 'Electricity & electronics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (538, 'Science', 'Physics', 'Magnetism')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (539, 'Science', 'Physics', 'Modern physics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (540, 'Science', 'Chemistry', 'Chemistry & allied sciences')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (541, 'Science', 'Chemistry', 'Physical chemistry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (542, 'Science', 'Chemistry', 'Techniques, procedures, apparatus, equipment, materials')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (543, 'Science', 'Chemistry', 'Analytical chemistry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (544, 'Science', 'Chemistry', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (545, 'Science', 'Chemistry', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (546, 'Science', 'Chemistry', 'Inorganic chemistry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (547, 'Science', 'Chemistry', 'Organic chemistry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (548, 'Science', 'Chemistry', 'Crystallography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (549, 'Science', 'Chemistry', 'Mineralogy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (550, 'Science', 'Earth sciences & geology', 'Earth sciences')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (551, 'Science', 'Earth sciences & geology', 'Geology, hydrology, meteorology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (552, 'Science', 'Earth sciences & geology', 'Petrology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (553, 'Science', 'Earth sciences & geology', 'Economic geology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (554, 'Science', 'Earth sciences & geology', 'Earth sciences of Europe')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (555, 'Science', 'Earth sciences & geology', 'Earth sciences of Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (556, 'Science', 'Earth sciences & geology', 'Earth sciences of Africa')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (557, 'Science', 'Earth sciences & geology', 'Earth sciences of North America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (558, 'Science', 'Earth sciences & geology', 'Earth sciences of South America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (559, 'Science', 'Earth sciences & geology', 'Earth sciences of Australasia, Pacific Ocean islands, Atlantic Ocean islands, Arctic islands, Antarctica, extraterrestrial worlds')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (560, 'Science', 'Fossils & prehistoric life', 'Paleontology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (561, 'Science', 'Fossils & prehistoric life', 'Paleobotany; fossil microorganisms')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (562, 'Science', 'Fossils & prehistoric life', 'Fossil invertebrates')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (563, 'Science', 'Fossils & prehistoric life', 'Miscellaneous fossil marine & seashore invertebrates')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (564, 'Science', 'Fossils & prehistoric life', 'Fossil Mollusca & Molluscoidea')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (565, 'Science', 'Fossils & prehistoric life', 'Fossil Arthropoda')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (566, 'Science', 'Fossils & prehistoric life', 'Fossil Chordata')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (567, 'Science', 'Fossils & prehistoric life', 'Fossil cold-blooded vertebrates')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (568, 'Science', 'Fossils & prehistoric life', 'Fossil Aves (birds)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (569, 'Science', 'Fossils & prehistoric life', 'Fossil Mammalia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (570, 'Science', 'Biology', 'Biology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (571, 'Science', 'Biology', 'Physiology & related subjects')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (572, 'Science', 'Biology', 'Biochemistry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (573, 'Science', 'Biology', 'Specific physiological systems in animals, regional histology & physiology in animals')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (574, 'Science', 'Biology', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (575, 'Science', 'Biology', 'Specific parts of & physiological systems in plants')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (576, 'Science', 'Biology', 'Genetics and evolution')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (577, 'Science', 'Biology', 'Ecology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (578, 'Science', 'Biology', 'Natural history of organisms & related subjects')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (579, 'Science', 'Biology', 'Natural history of microorganisms, fungi, algae')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (580, 'Science', 'Plants', 'Plants')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (581, 'Science', 'Plants', 'Specific topics in natural history of plants')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (582, 'Science', 'Plants', 'Plants noted for specific vegetative characteristics and flowers')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (583, 'Science', 'Plants', 'Magnoliopsida (Dicotyledones)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (584, 'Science', 'Plants', 'Liliopsida (Monocotyledones)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (585, 'Science', 'Plants', 'Pinophyta (Gymnosperms)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (586, 'Science', 'Plants', 'Cryptogamia (Seedless plants)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (587, 'Science', 'Plants', 'Pteridophyta')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (588, 'Science', 'Plants', 'Bryophyta')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (589, 'Science', 'Plants', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (590, 'Science', 'Animals (Zoology)', 'Animals')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (591, 'Science', 'Animals (Zoology)', 'Specific topics in natural history of animals')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (592, 'Science', 'Animals (Zoology)', 'Invertebrates')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (593, 'Science', 'Animals (Zoology)', 'Miscellaneous marine & seashore invertebrates')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (594, 'Science', 'Animals (Zoology)', 'Mollusca & Molluscoidea')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (595, 'Science', 'Animals (Zoology)', 'Arthropoda')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (596, 'Science', 'Animals (Zoology)', 'Chordata')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (597, 'Science', 'Animals (Zoology)', 'Cold-blooded vertebrates')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (598, 'Science', 'Animals (Zoology)', 'Aves (Birds)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (599, 'Science', 'Animals (Zoology)', 'Mammalia (Mammals)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (600, 'Technology', 'Technology', 'Technology (Applied sciences)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (601, 'Technology', 'Technology', 'Philosophy & theory')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (602, 'Technology', 'Technology', 'Miscellany')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (603, 'Technology', 'Technology', 'Dictionaries, encyclopedias, concordances')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (604, 'Technology', 'Technology', 'Technical drawing, hazardous materials technology; groups of people')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (605, 'Technology', 'Technology', 'Serial publications')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (606, 'Technology', 'Technology', 'Organizations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (607, 'Technology', 'Technology', 'Education, research, related topics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (608, 'Technology', 'Technology', 'Patents')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (609, 'Technology', 'Technology', 'History, geographic treatment, biography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (610, 'Technology', 'Medicine & health', 'Medicine & health')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (611, 'Technology', 'Medicine & health', 'Human anatomy, cytology, histology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (612, 'Technology', 'Medicine & health', 'Human physiology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (613, 'Technology', 'Medicine & health', 'Personal health & safety')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (614, 'Technology', 'Medicine & health', 'Forensic medicine; incidence of injuries, wounds, disease; public preventive medicine')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (615, 'Technology', 'Medicine & health', 'Pharmacology and therapeutics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (616, 'Technology', 'Medicine & health', 'Diseases')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (617, 'Technology', 'Medicine & health', 'Surgery, regional medicine, dentistry, ophthalmology, otology, audiology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (618, 'Technology', 'Medicine & health', 'Gynecology, obstetrics, pediatrics, geriatrics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (619, 'Technology', 'Medicine & health', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (620, 'Technology', 'Engineering', 'Engineering & Applied operations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (621, 'Technology', 'Engineering', 'Applied physics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (622, 'Technology', 'Engineering', 'Mining & related operations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (623, 'Technology', 'Engineering', 'Military & nautical engineering')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (624, 'Technology', 'Engineering', 'Civil engineering')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (625, 'Technology', 'Engineering', 'Engineering of railroads, roads')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (626, 'Technology', 'Engineering', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (627, 'Technology', 'Engineering', 'Hydraulic engineering')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (628, 'Technology', 'Engineering', 'Sanitary engineering')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (629, 'Technology', 'Engineering', 'Other branches of engineering')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (630, 'Technology', 'Agriculture', 'Agriculture & related technologies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (631, 'Technology', 'Agriculture', 'Specific techniques; apparatus, equipment, materials')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (632, 'Technology', 'Agriculture', 'Plant injuries, diseases, pests')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (633, 'Technology', 'Agriculture', 'Field & plantation crops')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (634, 'Technology', 'Agriculture', 'Orchards, fruits, forestry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (635, 'Technology', 'Agriculture', 'Garden crops (Horticulture)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (636, 'Technology', 'Agriculture', 'Animal husbandry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (637, 'Technology', 'Agriculture', 'Processing dairy & related products')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (638, 'Technology', 'Agriculture', 'Insect culture')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (639, 'Technology', 'Agriculture', 'Hunting, fishing, conservation, related technologies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (640, 'Technology', 'Home & family management', 'Home & family management')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (641, 'Technology', 'Home & family management', 'Food & drink')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (642, 'Technology', 'Home & family management', 'Meals & table service')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (643, 'Technology', 'Home & family management', 'Housing & household equipment')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (644, 'Technology', 'Home & family management', 'Household utilities')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (645, 'Technology', 'Home & family management', 'Household furnishings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (646, 'Technology', 'Home & family management', 'Sewing, clothing, management of personal and family life')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (647, 'Technology', 'Home & family management', 'Management of public households (Institutional housekeeping)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (648, 'Technology', 'Home & family management', 'Housekeeping')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (649, 'Technology', 'Home & family management', 'Child rearing; home care of people with disabilities & illnesses')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (650, 'Technology', 'Management & public relations', 'Management & auxiliary services')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (651, 'Technology', 'Management & public relations', 'Office services')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (652, 'Technology', 'Management & public relations', 'Processes of written communication')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (653, 'Technology', 'Management & public relations', 'Shorthand')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (654, 'Technology', 'Management & public relations', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (655, 'Technology', 'Management & public relations', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (656, 'Technology', 'Management & public relations', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (657, 'Technology', 'Management & public relations', 'Accounting')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (658, 'Technology', 'Management & public relations', 'General management')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (659, 'Technology', 'Management & public relations', 'Advertising & public relations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (660, 'Technology', 'Chemical engineering', 'Chemical engineering & related technologies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (661, 'Technology', 'Chemical engineering', 'Technology of industrial chemicals')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (662, 'Technology', 'Chemical engineering', 'Technology of explosives, fuels, related products')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (663, 'Technology', 'Chemical engineering', 'Beverage technology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (664, 'Technology', 'Chemical engineering', 'Food technology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (665, 'Technology', 'Chemical engineering', 'Technology of industrial oils, fats, waxes, gases')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (666, 'Technology', 'Chemical engineering', 'Ceramic & allied technologies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (667, 'Technology', 'Chemical engineering', 'Cleaning, color, coating, related technologies')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (668, 'Technology', 'Chemical engineering', 'Technology of other organic products')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (669, 'Technology', 'Chemical engineering', 'Metallurgy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (670, 'Technology', 'Manufacturing', 'Manufacturing')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (671, 'Technology', 'Manufacturing', 'Metalworking processes & primary metal products')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (672, 'Technology', 'Manufacturing', 'Iron, steel, other iron alloys')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (673, 'Technology', 'Manufacturing', 'Nonferrous metals')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (674, 'Technology', 'Manufacturing', 'Lumber processing, wood products, cork')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (675, 'Technology', 'Manufacturing', 'Leather & fur processing')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (676, 'Technology', 'Manufacturing', 'Pulp & paper technology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (677, 'Technology', 'Manufacturing', 'Textiles')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (678, 'Technology', 'Manufacturing', 'Elastomers & elastomer products')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (679, 'Technology', 'Manufacturing', 'Other products of specific kinds of materials')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (680, 'Technology', 'Manufacture for specific uses', 'Manufacture of products for specific uses')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (681, 'Technology', 'Manufacture for specific uses', 'Precision instruments & other devices')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (682, 'Technology', 'Manufacture for specific uses', 'Small forge work (Blacksmithing)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (683, 'Technology', 'Manufacture for specific uses', 'Hardware & household appliances')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (684, 'Technology', 'Manufacture for specific uses', 'Furnishings & home workshops')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (685, 'Technology', 'Manufacture for specific uses', 'Leather & fur goods, & related products')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (686, 'Technology', 'Manufacture for specific uses', 'Printing & related activities')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (687, 'Technology', 'Manufacture for specific uses', 'Clothing & accessories')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (688, 'Technology', 'Manufacture for specific uses', 'Other final products, & packaging technology')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (689, 'Technology', 'Manufacture for specific uses', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (690, 'Technology', 'Construction of buildings', 'Construction of buildings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (691, 'Technology', 'Construction of buildings', 'Building materials')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (692, 'Technology', 'Construction of buildings', 'Auxiliary construction practices')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (693, 'Technology', 'Construction of buildings', 'Construction in specific types of materials & for specific purposes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (694, 'Technology', 'Construction of buildings', 'Wood construction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (695, 'Technology', 'Construction of buildings', 'Roof covering')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (696, 'Technology', 'Construction of buildings', 'Utilities')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (697, 'Technology', 'Construction of buildings', 'Heating, ventilating, air-conditioning engineering')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (698, 'Technology', 'Construction of buildings', 'Detail finishing')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (699, 'Technology', 'Construction of buildings', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (700, 'Arts & recreation', 'Arts', 'The Arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (701, 'Arts & recreation', 'Arts', 'Philosophy & theory of fine & decorative arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (702, 'Arts & recreation', 'Arts', 'Miscellany of fine & decorative arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (703, 'Arts & recreation', 'Arts', 'Dictionaries, encyclopedias, concordances of fine & decorative arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (704, 'Arts & recreation', 'Arts', 'Special topics in fine & decorative arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (705, 'Arts & recreation', 'Arts', 'Serial publications of fine & decorative arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (706, 'Arts & recreation', 'Arts', 'Organizations & management of fine & decorative arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (707, 'Arts & recreation', 'Arts', 'Education, research, related topics of fine & decorative arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (708, 'Arts & recreation', 'Arts', 'Galleries, museums, private collections of fine & decorative arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (709, 'Arts & recreation', 'Arts', 'History, geographic treatment, biography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (710, 'Arts & recreation', 'Area planning & landscape architecture', 'Area planning & landscape architecture')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (711, 'Arts & recreation', 'Area planning & landscape architecture', 'Area planning (Civic art)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (712, 'Arts & recreation', 'Area planning & landscape architecture', 'Landscape architecture (Landscape design)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (713, 'Arts & recreation', 'Area planning & landscape architecture', 'Landscape architecture of trafficways')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (714, 'Arts & recreation', 'Area planning & landscape architecture', 'Water features in landscape architecture')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (715, 'Arts & recreation', 'Area planning & landscape architecture', 'Woody plants in landscape architecture')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (716, 'Arts & recreation', 'Area planning & landscape architecture', 'Herbaceous plants in landscape architecture')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (717, 'Arts & recreation', 'Area planning & landscape architecture', 'Structures in landscape architecture')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (718, 'Arts & recreation', 'Area planning & landscape architecture', 'Landscape design of cemeteries')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (719, 'Arts & recreation', 'Area planning & landscape architecture', 'Natural landscapes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (720, 'Arts & recreation', 'Architecture', 'Architecture')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (721, 'Arts & recreation', 'Architecture', 'Architectural materials & structural elements')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (722, 'Arts & recreation', 'Architecture', 'Architecture from earliest times to ca. 300')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (723, 'Arts & recreation', 'Architecture', 'Architecture from ca. 300 to 1399')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (724, 'Arts & recreation', 'Architecture', 'Architecture from 1400')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (725, 'Arts & recreation', 'Architecture', 'Public structures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (726, 'Arts & recreation', 'Architecture', 'Buildings for religious & related purposes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (727, 'Arts & recreation', 'Architecture', 'Buildings for educational & research purposes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (728, 'Arts & recreation', 'Architecture', 'Residential & related buildings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (729, 'Arts & recreation', 'Architecture', 'Design & decoration of structures & accessories')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (730, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Sculpture & related arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (731, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Processes, forms, subjects of sculpture')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (732, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Sculpture from earliest times to ca. 500, sculpture of nonliterate peoples')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (733, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Greek, Etruscan, Roman sculpture')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (734, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Sculpture from ca. 500 to 1399')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (735, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Sculpture from 1400')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (736, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Carving & carvings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (737, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Numismatics & sigillography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (738, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Ceramic arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (739, 'Arts & recreation', 'Sculpture, ceramics, & metalwork', 'Art metalwork')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (740, 'Arts & recreation', 'Graphic arts & decorative arts', 'Graphic arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (741, 'Arts & recreation', 'Graphic arts & decorative arts', 'Drawing & drawings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (742, 'Arts & recreation', 'Graphic arts & decorative arts', 'Perspective in drawing')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (743, 'Arts & recreation', 'Graphic arts & decorative arts', 'Drawing & drawings by subject')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (744, 'Arts & recreation', 'Graphic arts & decorative arts', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (745, 'Arts & recreation', 'Graphic arts & decorative arts', 'Decorative arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (746, 'Arts & recreation', 'Graphic arts & decorative arts', 'Textile arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (747, 'Arts & recreation', 'Graphic arts & decorative arts', 'Interior decoration')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (748, 'Arts & recreation', 'Graphic arts & decorative arts', 'Glass')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (749, 'Arts & recreation', 'Graphic arts & decorative arts', 'Furniture & accessories')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (750, 'Arts & recreation', 'Painting', 'Painting & paintings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (751, 'Arts & recreation', 'Painting', 'Techniques, procedures, apparatus, equipment, materials, forms')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (752, 'Arts & recreation', 'Painting', 'Color')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (753, 'Arts & recreation', 'Painting', 'Symbolism, allegory, mythology, legend')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (754, 'Arts & recreation', 'Painting', 'Genre paintings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (755, 'Arts & recreation', 'Painting', 'Religion')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (756, 'Arts & recreation', 'Painting', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (757, 'Arts & recreation', 'Painting', 'Human figures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (758, 'Arts & recreation', 'Painting', 'Nature, architectural subjects & cityscapes, other specific subjects')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (759, 'Arts & recreation', 'Painting', 'History, geographic treatment, biography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (760, 'Arts & recreation', 'Printmaking & prints', 'Printmaking & prints')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (761, 'Arts & recreation', 'Printmaking & prints', 'Relief processes (Block printing)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (762, 'Arts & recreation', 'Printmaking & prints', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (763, 'Arts & recreation', 'Printmaking & prints', 'Lithographic processes (Planographic processes)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (764, 'Arts & recreation', 'Printmaking & prints', 'Chromolithography & serigraphy')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (765, 'Arts & recreation', 'Printmaking & prints', 'Metal engraving')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (766, 'Arts & recreation', 'Printmaking & prints', 'Mezzotinting, aquatinting, & related processes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (767, 'Arts & recreation', 'Printmaking & prints', 'Etching & drypoint')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (768, 'Arts & recreation', 'Printmaking & prints', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (769, 'Arts & recreation', 'Printmaking & prints', 'Prints')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (770, 'Arts & recreation', 'Photography, computer art, film, video', 'Photography, computer art, cinematography, videography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (771, 'Arts & recreation', 'Photography, computer art, film, video', 'Techniques, procedures, apparatus, equipment, materials')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (772, 'Arts & recreation', 'Photography, computer art, film, video', 'Metallic salt processes')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (773, 'Arts & recreation', 'Photography, computer art, film, video', 'Pigment processes of printing')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (774, 'Arts & recreation', 'Photography, computer art, film, video', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (775, 'Arts & recreation', 'Photography, computer art, film, video', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (776, 'Arts & recreation', 'Photography, computer art, film, video', 'Computer art (Digital art)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (777, 'Arts & recreation', 'Photography, computer art, film, video', 'Cinematography & Videography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (778, 'Arts & recreation', 'Photography, computer art, film, video', 'Specific fields & special kinds of photography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (779, 'Arts & recreation', 'Photography, computer art, film, video', 'Photographic images')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (780, 'Arts & recreation', 'Music', 'Music')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (781, 'Arts & recreation', 'Music', 'General principles & musical forms')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (782, 'Arts & recreation', 'Music', 'Vocal music')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (783, 'Arts & recreation', 'Music', 'Music for single voices')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (784, 'Arts & recreation', 'Music', 'Instruments & Instrumental ensembles & their music')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (785, 'Arts & recreation', 'Music', 'Ensembles with only one instrument per part')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (786, 'Arts & recreation', 'Music', 'Keyboard, mechanical, electrophonic, percussion instruments')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (787, 'Arts & recreation', 'Music', 'Stringed instruments (Chordophones)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (788, 'Arts & recreation', 'Music', 'Wind instruments (Aerophones)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (789, 'Arts & recreation', 'Music', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (790, 'Arts & recreation', 'Sports, games & entertainment', 'Recreational & performing arts')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (791, 'Arts & recreation', 'Sports, games & entertainment', 'Public performances')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (792, 'Arts & recreation', 'Sports, games & entertainment', 'Stage presentations')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (793, 'Arts & recreation', 'Sports, games & entertainment', 'Indoor games & amusements')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (794, 'Arts & recreation', 'Sports, games & entertainment', 'Indoor games of skill')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (795, 'Arts & recreation', 'Sports, games & entertainment', 'Games of chance')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (796, 'Arts & recreation', 'Sports, games & entertainment', 'Athletic & outdoor sports & games')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (797, 'Arts & recreation', 'Sports, games & entertainment', 'Aquatic & air sports')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (798, 'Arts & recreation', 'Sports, games & entertainment', 'Equestrian sports & animal racing')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (799, 'Arts & recreation', 'Sports, games & entertainment', 'Fishing, hunting, shooting')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (800, 'Literature', 'Literature, rhetoric & criticism', 'Literature (Belles-lettres) & rhetoric')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (801, 'Literature', 'Literature, rhetoric & criticism', 'Philosophy & theory')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (802, 'Literature', 'Literature, rhetoric & criticism', 'Miscellany')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (803, 'Literature', 'Literature, rhetoric & criticism', 'Dictionaries, encyclopedias, concordances')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (804, 'Literature', 'Literature, rhetoric & criticism', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (805, 'Literature', 'Literature, rhetoric & criticism', 'Serial publications')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (806, 'Literature', 'Literature, rhetoric & criticism', 'Organizations & management')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (807, 'Literature', 'Literature, rhetoric & criticism', 'Education, research, related topics')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (808, 'Literature', 'Literature, rhetoric & criticism', 'Rhetoric & collections of literary texts from more than two literatures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (809, 'Literature', 'Literature, rhetoric & criticism', 'History, description, critical appraisal of more than two literatures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (810, 'Literature', 'American literature in English', 'American literature in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (811, 'Literature', 'American literature in English', 'American poetry in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (812, 'Literature', 'American literature in English', 'American drama in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (813, 'Literature', 'American literature in English', 'American fiction in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (814, 'Literature', 'American literature in English', 'American essays in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (815, 'Literature', 'American literature in English', 'American speeches in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (816, 'Literature', 'American literature in English', 'American letters in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (817, 'Literature', 'American literature in English', 'American humor & satire in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (818, 'Literature', 'American literature in English', 'American miscellaneous writings in English')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (819, 'Literature', 'American literature in English', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (820, 'Literature', 'English & Old English literatures', 'English & Old English (Anglo-Saxon) literatures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (821, 'Literature', 'English & Old English literatures', 'English Poetry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (822, 'Literature', 'English & Old English literatures', 'English drama')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (823, 'Literature', 'English & Old English literatures', 'English fiction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (824, 'Literature', 'English & Old English literatures', 'English essays')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (825, 'Literature', 'English & Old English literatures', 'English speeches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (826, 'Literature', 'English & Old English literatures', 'English letters')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (827, 'Literature', 'English & Old English literatures', 'English humor & satire')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (828, 'Literature', 'English & Old English literatures', 'English miscellaneous writings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (829, 'Literature', 'English & Old English literatures', 'Old English (Anglo-Saxon) literature')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (830, 'Literature', 'German & related literatures', 'German literature & literatures of related languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (831, 'Literature', 'German & related literatures', 'German poetry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (832, 'Literature', 'German & related literatures', 'German drama')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (833, 'Literature', 'German & related literatures', 'German fiction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (834, 'Literature', 'German & related literatures', 'German essays')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (835, 'Literature', 'German & related literatures', 'German speeches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (836, 'Literature', 'German & related literatures', 'German letters')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (837, 'Literature', 'German & related literatures', 'German humor & satire')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (838, 'Literature', 'German & related literatures', 'German miscellaneous writings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (839, 'Literature', 'German & related literatures', 'Other Germanic literatures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (840, 'Literature', 'French & related literatures', 'French literature & literatures of related Romance languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (841, 'Literature', 'French & related literatures', 'French poetry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (842, 'Literature', 'French & related literatures', 'French drama')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (843, 'Literature', 'French & related literatures', 'French fiction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (844, 'Literature', 'French & related literatures', 'French essays')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (845, 'Literature', 'French & related literatures', 'French speeches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (846, 'Literature', 'French & related literatures', 'French letters')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (847, 'Literature', 'French & related literatures', 'French humor & satire')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (848, 'Literature', 'French & related literatures', 'French miscellaneous writings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (849, 'Literature', 'French & related literatures', 'Occitan, Catalan, Franco-Provençal literatures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (850, 'Literature', 'Italian, Romanian, & related literatures', 'Literatures of Italian, Dalmatian, Romanian, Rhaetian, Sardinian, Corsican languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (851, 'Literature', 'Italian, Romanian, & related literatures', 'Italian poetry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (852, 'Literature', 'Italian, Romanian, & related literatures', 'Italiandrama')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (853, 'Literature', 'Italian, Romanian, & related literatures', 'Italian fiction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (854, 'Literature', 'Italian, Romanian, & related literatures', 'Italian essays')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (855, 'Literature', 'Italian, Romanian, & related literatures', 'Italian speeches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (856, 'Literature', 'Italian, Romanian, & related literatures', 'Italian letters')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (857, 'Literature', 'Italian, Romanian, & related literatures', 'Italian humor & satire')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (858, 'Literature', 'Italian, Romanian, & related literatures', 'Italian miscellaneous writings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (859, 'Literature', 'Italian, Romanian, & related literatures', 'Literatures of Romanian, Rhaetian, Sardinian, Corsican languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (860, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Literatures of Spanish, Portuguese, Galician languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (861, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Spanish poetry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (862, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Spanish drama')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (863, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Spanish fiction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (864, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Spanish essays')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (865, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Spanish speeches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (866, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Spanish letters')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (867, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Spanish humor & satire')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (868, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Spanish miscellaneous writings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (869, 'Literature', 'Spanish, Portuguese, Galician literatures', 'Literatures of Portuguese & Galician languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (870, 'Literature', 'Latin & Italic literatures', 'Latin literature & literatures of related Italic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (871, 'Literature', 'Latin & Italic literatures', 'Latin poetry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (872, 'Literature', 'Latin & Italic literatures', 'Latin dramatic poetry & drama')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (873, 'Literature', 'Latin & Italic literatures', 'Latin epic poetry & drama')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (874, 'Literature', 'Latin & Italic literatures', 'Latin lyric poetry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (875, 'Literature', 'Latin & Italic literatures', 'Latin speeches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (876, 'Literature', 'Latin & Italic literatures', 'Latin letters')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (877, 'Literature', 'Latin & Italic literatures', 'Latin humor & satire')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (878, 'Literature', 'Latin & Italic literatures', 'Latin miscellaneous writings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (879, 'Literature', 'Latin & Italic literatures', 'Literatures of other Italic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (880, 'Literature', 'Classical & modern Greek literatures', 'Classical Greek literature & literatures of related Hellenic languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (881, 'Literature', 'Classical & modern Greek literatures', 'Classical Greek poetry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (882, 'Literature', 'Classical & modern Greek literatures', 'Classical Greek drama')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (883, 'Literature', 'Classical & modern Greek literatures', 'Classical Greek epic poetry & fiction')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (884, 'Literature', 'Classical & modern Greek literatures', 'Classical Greek lyric poetry')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (885, 'Literature', 'Classical & modern Greek literatures', 'Classical Greek speeches')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (886, 'Literature', 'Classical & modern Greek literatures', 'Classical Greek letters')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (887, 'Literature', 'Classical & modern Greek literatures', 'Classical Greek humor & satire')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (888, 'Literature', 'Classical & modern Greek literatures', 'Classical Greek miscellaneous writings')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (889, 'Literature', 'Classical & modern Greek literatures', 'Modern Greek literature')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (890, 'Literature', 'Other literatures', 'Literatures of other specific languages and language families')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (891, 'Literature', 'Other literatures', 'East Indo-European & Celtic literatures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (892, 'Literature', 'Other literatures', 'Afro-Asiatic literatures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (893, 'Literature', 'Other literatures', 'Non-Semitic Afro-Asiatic literatures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (894, 'Literature', 'Other literatures', 'Literatures of Altaic, Uralic, Hyperborean, Dravidian languages; literatures of miscellaneous languages of Southeast Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (895, 'Literature', 'Other literatures', 'Literatures of East & Southeast Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (896, 'Literature', 'Other literatures', 'African literatures')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (897, 'Literature', 'Other literatures', 'Literatures of North American native languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (898, 'Literature', 'Other literatures', 'Literatures of South American native languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (899, 'Literature', 'Other literatures', 'Literatures of non-Austronesian languages of Oceania, of Austronesian languages, of miscellaneous languages')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (900, 'History & geography', 'History', 'History, geography, & auxiliary disciplines')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (901, 'History & geography', 'History', 'Philosophy & theory of history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (902, 'History & geography', 'History', 'Miscellany of history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (903, 'History & geography', 'History', 'Dictionaries, encyclopedias, concordances of history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (904, 'History & geography', 'History', 'Collected accounts of events')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (905, 'History & geography', 'History', 'Serial publications of history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (906, 'History & geography', 'History', 'Organizations & management of history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (907, 'History & geography', 'History', 'Education, research, related topics of history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (908, 'History & geography', 'History', 'History with respect to groups of people')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (909, 'History & geography', 'History', 'World history')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (910, 'History & geography', 'Geography & travel', 'Geography & travel')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (911, 'History & geography', 'Geography & travel', 'Historical geography')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (912, 'History & geography', 'Geography & travel', 'Graphic representations of surface of earth and of extraterrestrial worlds')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (913, 'History & geography', 'Geography & travel', 'Geography of & travel in ancient world')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (914, 'History & geography', 'Geography & travel', 'Geography of & travel in Europe')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (915, 'History & geography', 'Geography & travel', 'Geography of & travel in Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (916, 'History & geography', 'Geography & travel', 'Geography of & travel in Africa')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (917, 'History & geography', 'Geography & travel', 'Geography of & travel in North America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (918, 'History & geography', 'Geography & travel', 'Geography of & travel in South America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (919, 'History & geography', 'Geography & travel', 'Geography of & travel in Australasia, Pacific Ocean islands, Atlantic Ocean islands, Arctic islands, Antarctica, & on extraterrestrial worlds')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (920, 'History & geography', 'Biography & genealogy', 'Biography, genealogy, insignia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (921, 'History & geography', 'Biography & genealogy', 'Optional location for biographies, sorted alphabetically by subjects last name')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (922, 'History & geography', 'Biography & genealogy', 'Optional location for biographies, sorted alphabetically by subjects last name')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (923, 'History & geography', 'Biography & genealogy', 'Optional location for biographies, sorted alphabetically by subjects last name')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (924, 'History & geography', 'Biography & genealogy', 'Optional location for biographies, sorted alphabetically by subjects last name')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (925, 'History & geography', 'Biography & genealogy', 'Optional location for biographies, sorted alphabetically by subjects last name')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (926, 'History & geography', 'Biography & genealogy', 'Optional location for biographies, sorted alphabetically by subjects last name')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (927, 'History & geography', 'Biography & genealogy', 'Optional location for biographies, sorted alphabetically by subjects last name')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (928, 'History & geography', 'Biography & genealogy', 'Optional location for biographies, sorted alphabetically by subjects last name')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (929, 'History & geography', 'Biography & genealogy', 'Genealogy, names, insignia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (930, 'History & geography', 'History of ancient world (to ca. 499)', 'History of ancient world to ca. 499')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (931, 'History & geography', 'History of ancient world (to ca. 499)', 'China to 420')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (932, 'History & geography', 'History of ancient world (to ca. 499)', 'Egypt to 640')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (933, 'History & geography', 'History of ancient world (to ca. 499)', 'Palestine to 70')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (934, 'History & geography', 'History of ancient world (to ca. 499)', 'South Asia to 647')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (935, 'History & geography', 'History of ancient world (to ca. 499)', 'Mesopotamia to 637 & Iranian Plateau to 637')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (936, 'History & geography', 'History of ancient world (to ca. 499)', 'Europe north & west of Italian Peninsula to ca. 499')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (937, 'History & geography', 'History of ancient world (to ca. 499)', 'Italian Peninsula to 476 & adjacent territories to 476')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (938, 'History & geography', 'History of ancient world (to ca. 499)', 'Greece to 323')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (939, 'History & geography', 'History of ancient world (to ca. 499)', 'Other parts of ancient world')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (940, 'History & geography', 'History of Europe', 'History of Europe')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (941, 'History & geography', 'History of Europe', 'British Isles')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (942, 'History & geography', 'History of Europe', 'England & Wales')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (943, 'History & geography', 'History of Europe', 'Germany & neighboring central European countries')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (944, 'History & geography', 'History of Europe', 'France & Monaco')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (945, 'History & geography', 'History of Europe', 'Italy, San Marino, Vatican City, Malta')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (946, 'History & geography', 'History of Europe', 'Spain, Andorra, Gibraltar, Portugal')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (947, 'History & geography', 'History of Europe', 'Russia & neighboring east European countries')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (948, 'History & geography', 'History of Europe', 'Scandinavia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (949, 'History & geography', 'History of Europe', 'Other parts of Europe')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (950, 'History & geography', 'History of Asia', 'History of Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (951, 'History & geography', 'History of Asia', 'China & adjacent areas')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (952, 'History & geography', 'History of Asia', 'Japan')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (953, 'History & geography', 'History of Asia', 'Arabian Peninsula & adjacent areas')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (954, 'History & geography', 'History of Asia', 'India & neighboring south Asian countries;')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (955, 'History & geography', 'History of Asia', 'Iran')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (956, 'History & geography', 'History of Asia', 'Middle East (Near East)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (957, 'History & geography', 'History of Asia', 'Siberia (Asiatic Russia)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (958, 'History & geography', 'History of Asia', 'Central Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (959, 'History & geography', 'History of Asia', 'Southeast Asia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (960, 'History & geography', 'History of Africa', 'History of Africa')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (961, 'History & geography', 'History of Africa', 'Tunisia & Libya')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (962, 'History & geography', 'History of Africa', 'Egypt, Sudan, South Sudan')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (963, 'History & geography', 'History of Africa', 'Ethiopia & Eritrea')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (964, 'History & geography', 'History of Africa', 'Morocco, Ceuta, Melilla Western Sahara, Canary Islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (965, 'History & geography', 'History of Africa', 'Algeria')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (966, 'History & geography', 'History of Africa', 'West Africa & offshore islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (967, 'History & geography', 'History of Africa', 'Central Africa & offshore islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (968, 'History & geography', 'History of Africa', 'Republic of South Africa & neighboring southern African countries')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (969, 'History & geography', 'History of Africa', 'South Indian Ocean islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (970, 'History & geography', 'History of North America', 'History of North America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (971, 'History & geography', 'History of North America', 'Canada')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (972, 'History & geography', 'History of North America', 'Mexico, Central America, West Indies, Bermuda')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (973, 'History & geography', 'History of North America', 'United States')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (974, 'History & geography', 'History of North America', 'Northeastern United States (New England & Middle Atlantic states)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (975, 'History & geography', 'History of North America', 'Southeastern United States (South Atlantic states)')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (976, 'History & geography', 'History of North America', 'South central United States')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (977, 'History & geography', 'History of North America', 'North central United States')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (978, 'History & geography', 'History of North America', 'Western United States')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (979, 'History & geography', 'History of North America', 'Great Basin & Pacific Slope region of United States')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (980, 'History & geography', 'History of South America', 'History of South America')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (981, 'History & geography', 'History of South America', 'Brazil')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (982, 'History & geography', 'History of South America', 'Argentina')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (983, 'History & geography', 'History of South America', 'Chile')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (984, 'History & geography', 'History of South America', 'Bolivia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (985, 'History & geography', 'History of South America', 'Peru')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (986, 'History & geography', 'History of South America', 'Colombia & Ecuador')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (987, 'History & geography', 'History of South America', 'Venezuela')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (988, 'History & geography', 'History of South America', 'Guiana')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (989, 'History & geography', 'History of South America', 'Paraguay & Uruguay')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (990, 'History & geography', 'History of other areas', 'History of Australasia, Pacific Ocean islands, Atlantic Ocean islands, Arctic islands, Antarctica, extraterrestrial worlds')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (991, 'History & geography', 'History of other areas', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (992, 'History & geography', 'History of other areas', '[Unassigned]')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (993, 'History & geography', 'History of other areas', 'New Zealand')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (994, 'History & geography', 'History of other areas', 'Australia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (995, 'History & geography', 'History of other areas', 'New Guinea & neighboring countries of Melanesia')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (996, 'History & geography', 'History of other areas', 'Polynesia & other Pacific Ocean islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (997, 'History & geography', 'History of other areas', 'Atlantic Ocean islands')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (998, 'History & geography', 'History of other areas', 'Arctic islands & Antarctica')
INSERT INTO DeweyDecimal(DDNumber, Class, Division, Section) VALUES (999, 'History & geography', 'History of other areas', 'Extraterrestrial worlds')
SET IDENTITY_INSERT DeweyDecimal OFF

INSERT INTO Employees (EmployeeID, LoginID, JobTitle, CurrentFlag, EmailID, BirthDate, HireDate, ModifiedDate, ModifiedBy) VALUES (4, 'grud75', 'Library Supervisor', 1, 1, '02-12-1975', '09-18-2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Employees (EmployeeID, LoginID, JobTitle, CurrentFlag, EmailID, BirthDate, HireDate, ModifiedDate, ModifiedBy) VALUES (10, 'dhel78', 'Archivist', 1, 6, '10-07-1978', '09-18-2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Employees (EmployeeID, LoginID, JobTitle, CurrentFlag, EmailID, BirthDate, HireDate, ModifiedDate, ModifiedBy) VALUES (17, 'abon71', 'Library Technician', 1, 9, '06-19-71', '09-18-2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Employees (EmployeeID, LoginID, JobTitle, CurrentFlag, EmailID, BirthDate, HireDate, ModifiedDate, ModifiedBy) VALUES (27, 'cpag90', 'Library Aide', 1, 12, '07-19-90', '09-18-2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Employees (EmployeeID, LoginID, JobTitle, CurrentFlag, EmailID, BirthDate, HireDate, ModifiedDate, ModifiedBy) VALUES (37, 'kkan89', 'Library Aide', 1, 17, '03-25-89', '09-18-2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Employees (EmployeeID, LoginID, JobTitle, CurrentFlag, EmailID, BirthDate, HireDate, ModifiedDate, ModifiedBy) VALUES (38, NULL, 'Volunteer Library Shelver', 0, 18, '03-26-1983', '11-06-2017', GETDATE(), ORIGINAL_LOGIN())

insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Family Secrets (Familjehemligheter)', null, null, null, 2, 2, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Jesse Stone: Sea Change', 946, 49, '06/28/1976', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Li''l Abner', 909, 2, '03/27/1972', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Saint Laurent', 682, 35, '08/27/1925', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Sleuth', 657, 16, '10/20/1938', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('The Crown Jewels', 191, 44, '02/28/1980', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Cowboy Way, The', 538, 41, '10/18/1962', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('All Night Long', 461, 50, '12/04/2008', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Covenant, The', 945, 14, '05/14/1962', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Pay It Forward', null, null, null, 2, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Python', 917, 9, '06/12/1925', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Bullet', 130, 18, '02/11/1987', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Solo ', 825, 36, '06/11/2002', 3, 0, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Battlestar Galactica', 880, 35, '01/22/1936', 3, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('My Boyfriend''s Back', 403, 48, '10/26/1920', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Stoning of Soraya M., The', 791, 2, '11/29/1967', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('The Invisible Frame', null, null, null, 2, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('The Inhabited Island', 570, 49, '06/14/1929', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Sherlock Holmes', 827, 40, '09/05/1942', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Game of Werewolves', 525, 18, '10/21/1948', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Piglet''s Big Movie', 308, 11, '06/11/1966', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Little Dieter Needs to Fly', 36, 1, '06/21/1966', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('American Zombie', 195, 41, '04/28/2012', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Master, The (Huang Fei Hong jiu er zhi long xing tian xia)', 713, 2, '01/08/1982', 4, 0, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Castaway', 236, 23, '10/21/1923', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Dhobi Ghat', 578, 40, '04/01/1961', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Just Cause', 523, 48, '09/05/1935', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Times Square', 359, 44, '03/01/1997', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Django Unchained', null, null, null, 2, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('True Grit', null, null, null, 2, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Carry on Cruising', 203, 36, '04/29/1924', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Woodsman and the Rain (Kitsutsuki to ame)', 313, 16, '05/04/1960', 1, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('All Quiet on the Western Front', 880, 14, '01/15/1979', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Madam Satan', 261, 41, '03/02/2006', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Portrait Werner Herzog', 861, 11, '12/20/1934', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Cutting Edge: The Magic of Movie Editing, The', 604, 50, '12/26/1969', 4, 0, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Open Heart', 175, 11, '07/14/1941', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Godzilla (Gojira)', 599, 23, '07/23/1938', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Call Northside 777', 105, 2, '07/06/1955', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Lake Mungo', 815, 9, '07/06/1962', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Expendables, The', null, null, null, 2, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Three Lives and Only One Death (Trois vies & une seule mort)', 804, 49, '11/28/2005', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Frownland', 524, 41, '09/17/1936', 3, 2, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('On the Town', 781, 9, '06/11/1962', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('The Car', 758, 41, '06/06/1956', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Animal Factory', null, null, null, 2, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Dummy', 749, 14, '03/03/1987', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Targets', 334, 36, '03/17/1946', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Café Metropole', 301, 50, '09/02/1945', 1, 2, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Pancho, the Millionaire Dog', 575, 49, '09/14/1967', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Unlawful Entry', 316, 18, '07/29/1971', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('To Hell and Back', 43, 19, '08/24/1973', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Witches'' Hammer (Kladivo na carodejnice) ', 356, 18, '12/04/1959', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Joe''s Apartment', 602, 16, '04/17/1931', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Wasp Woman, The', 393, 40, '11/13/1923', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Horror Planet (a.k.a. Inseminoid)', 271, 2, '09/25/1984', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Goal II: Living the Dream', 107, 9, '08/04/1972', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Night Train', 179, 35, '01/02/2009', 1, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Book of Love', 820, 11, '11/27/1967', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Enter the Ninja (a.k.a. Ninja I)', 431, 49, '08/14/1958', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Artist and the Model, The (El artista y la modelo)', null, null, null, 2, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Stars and Bars', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Miracle Worker, The', null, null, null, 2, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('The Man Who Shook the Hand of Vicente Fernandez', null, null, null, 2, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Broken Flowers', null, null, null, 2, 2, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Poison', 189, 11, '12/16/1998', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Alps (Alpeis)', 850, 36, '04/10/1986', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Humoresque', 170, 1, '06/20/2002', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Zombie High', 494, 9, '02/26/2003', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Backtrack (Catchfire)', 886, 23, '04/30/1988', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('The Arrival of Joachim Stiller', 840, 44, '10/21/1973', 3, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Quiet, The', 951, 9, '07/10/1967', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Invaders from Mars', 522, 36, '10/17/1966', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Oblivion', 318, 11, '01/25/1975', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Kurt & Courtney', 114, 14, '12/01/1984', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Wavelength', 716, 44, '06/30/1988', 3, 2, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Eccentricities of a Blonde-haired Girl (Singularidades de uma Rapariga Loura)', null, null, null, 2, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Guest House Paradiso', 616, 48, '12/18/1961', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Three Kings', 619, 50, '01/18/1995', 3, 0, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Wrong Move, The (Falsche Bewegung)', 377, 9, '05/30/2005', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Mothra (Mosura)', null, null, null, 2, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Summertime', 272, 14, '10/18/1992', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Happiness', 734, 44, '01/06/1991', 1, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('4 Little Girls', 568, 16, '12/01/2004', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Silent World, The (Le monde du silence)', null, null, null, 2, 2, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Other Side of Heaven, The', null, null, null, 2, 0, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Best Man Down', 564, 44, '03/31/1983', 4, 2, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('3 Little Ninjas and the Lost Treasure', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Last Rites of Joe May, The', 582, 23, '04/27/1982', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Old Man Drinking a Glass of Beer', 182, 48, '09/22/1925', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Kung Fu Dunk', 981, 2, '12/15/1994', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Louis C.K.: Chewed Up', 762, 18, '01/07/1932', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Road to Ruin, The', 758, 40, '04/18/1982', 4, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Glass Shield, The', null, null, null, 2, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Charlie''s Angels: Full Throttle', 254, 40, '03/26/1946', 3, 2, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Bag Man, The', 524, 40, '01/23/1942', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Camelot', 16, 48, '11/07/1978', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('All is Bright', 932, 50, '08/07/1920', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('A House of Secrets: Exploring ''Dragonwyck''', 429, 50, '08/22/2009', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Faster Pussycat! Kill! Kill!', 814, 14, '01/25/1948', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Silja - nuorena nukkunut', 983, 1, '03/18/1947', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Vampires', 823, 41, '05/26/1920', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Other Side of Heaven, The', 548, 1, '12/10/1967', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Tanner Hall', 439, 2, '03/01/1956', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Pathfinder (Ofelas)', null, null, null, 2, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Prick Up Your Ears', 885, 2, '05/07/2008', 1, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Lady and the Tramp', 644, 35, '01/11/1937', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Château, The', 77, 23, '06/11/1927', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('White Heat', 833, 14, '11/30/1992', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Camarón: When Flamenco Became Legend', 566, 48, '10/29/1955', 4, 1, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Babe', null, null, null, 2, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Alice (Neco z Alenky)', 833, 49, '10/15/1959', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Trial and Error', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Hard Way, The', 423, 2, '12/07/1999', 4, 1, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Surf Ninjas', 478, 41, '01/27/1978', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Johnny Apollo', 625, 16, '03/22/1976', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Men to Kiss', 643, 35, '08/22/1975', 3, 0, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Diary of Anne Frank, The', 769, 18, '06/11/1998', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Favela Rising', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Invitation to a Gunfighter', 805, 41, '08/30/1950', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Next', 286, 50, '11/17/2003', 3, 0, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Dogs of War, The', 893, 2, '02/06/2004', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Male and Female', 577, 36, '10/09/1955', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('My Stepmother Is an Alien', 473, 48, '02/12/1995', 3, 2, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Bling Ring, The', 345, 48, '04/10/1924', 3, 2, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Beowulf & Grendel', 189, 14, '06/17/1999', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Velocity of Gary, The', 398, 16, '12/30/1921', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('BloodRayne: The Third Reich', 482, 1, '03/21/1959', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Wings of the Dove, The', 66, 11, '11/01/2012', 1, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('$ellebrity (Sellebrity)', 150, 35, '06/13/1984', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Fright Night', 507, 40, '11/10/1931', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Escape to Witch Mountain', 100, 1, '10/16/1963', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('33 Postcards', 158, 35, '05/23/1953', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Cargo 200 (Gruz 200)', 612, 44, '04/22/1950', 4, 1, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Napoleon and Samantha', 355, 41, '02/23/1927', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Angels Crest', null, null, null, 2, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('War on Democracy, The', 373, 23, '06/20/1922', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Never Back Down', 870, 44, '09/26/2003', 3, 2, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('What Have I Done to Deserve This? (¿Qué he hecho yo para merecer esto!!)', null, null, null, 2, 1, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Tyson', null, null, null, 2, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Frank and Ollie', 980, 14, '06/04/1996', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Ice Princess', 296, 16, '03/01/1997', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Nas: Time Is Illmatic', 675, 44, '02/13/1945', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Saint in London, The', 68, 35, '08/14/2005', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('G.I. Joe: The Movie', 931, 16, '11/17/1935', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Discreet Charm of the Bourgeoisie, The (Charme discret de la bourgeoisie, Le)', 689, 44, '07/08/1923', 3, 2, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Red Violin, The (Violon rouge, Le)', 688, 2, '12/12/1935', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Vieraalla maalla', 204, 23, '05/21/1928', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Kapitalism: Our Improved Formula (Kapitalism - Reteta noastra secreta)', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Sun Wind (Aurinkotuuli)', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Female Prisoner #701: Scorpion (Joshuu 701-gô: Sasori)', 919, 16, '08/26/1941', 1, 2, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Goodbye Pork Pie', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Littlest Rebel, The', 925, 1, '06/27/1967', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Easy Virtue', 922, 18, '10/29/2007', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Human Resources (Ressources humaines)', 521, 9, '09/14/1975', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('The Broken Jug', 404, 44, '08/07/1952', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Something to Sing About', 593, 48, '11/08/1942', 4, 2, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Tell No One (Ne le dis à personne)', 360, 35, '07/27/1937', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Filming ''Othello''', 4, 40, '04/05/1983', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Container', 636, 35, '03/20/1944', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Sex & Drugs & Rock & Roll', 606, 36, '07/28/1927', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Miguel and William (Miguel y William)', 63, 9, '10/10/1956', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Frenchman''s Creek', 314, 2, '01/21/1922', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Chinaman (Kinamand)', 564, 49, '09/13/1964', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Queen Margot (Reine Margot, La)', 676, 16, '06/27/1988', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Superman/Doomsday ', 986, 49, '02/28/2011', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Desperate Journey', 155, 2, '07/31/1975', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Beautiful Dreamer: Brian Wilson and the Story of ''Smile''', 432, 48, '07/25/2008', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Shriek of the Mutilated', 621, 14, '08/15/1985', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Adult Camp', 215, 44, '08/29/1924', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Combat dans L''Ile, Le (Fire and Ice)', 667, 49, '09/16/1974', 1, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('She''s Gotta Have It', 965, 41, '05/09/1994', 4, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Private Life of Henry VIII, The', 774, 50, '08/08/1983', 4, 0, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Those Daring Young Men in Their Jaunty Jalopies', 5, 41, '01/07/2001', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Good Ol'' Freda', 855, 40, '11/02/1985', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Inner Life of Martin Frost, The', null, null, null, 2, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Alice Adams', 345, 1, '06/17/1989', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Girl from the Naked Eye, The', 670, 1, '02/02/1928', 3, 0, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('A Justified Life: Sam Peckinpah and the High Country', 239, 40, '06/10/1954', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Stars Fell on Henrietta, The', 805, 11, '06/10/1956', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Endless Love', 890, 16, '08/27/1920', 1, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Rubber', 43, 49, '07/13/1943', 3, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Rio Sex Comedy', 463, 44, '05/04/1941', 3, 1, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Anguish (Angustia)', 528, 49, '12/10/1983', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Peace, Propaganda & the Promised Land', 48, 41, '08/07/1974', 4, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Frozen', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('It Happened on Fifth Avenue', 586, 18, '03/16/1929', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Dying of the Light', 998, 14, '05/03/1990', 1, 0, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Wesley Willis: The Daddy of Rock ''n'' Roll', 872, 48, '09/30/1981', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Rutles 2: Can''t Buy Me Lunch, The', 955, 18, '07/29/1957', 1, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Babette Goes to War', 208, 18, '10/27/1933', 1, 1, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Monkey''s Paw, The', 158, 36, '12/11/1931', 3, 0, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Best Laid Plans', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('My Dog Skip', 733, 23, '01/27/1988', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Fame High', null, null, null, 2, 1, 2, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Losing Isaiah', 781, 35, '06/24/1941', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Tokyo Sonata', 222, 36, '02/07/1987', 3, 2, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Bent', 54, 23, '01/12/1978', 1, 2, 1, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('Needful Things', null, null, null, 2, 1, 0, GETDATE(), ORIGINAL_LOGIN());
insert into Publications (PubName, DDNumber, AuthorID, ReleaseDate, MediaID, Restriction, Removal, ModifiedDate, ModifiedBy) values ('...And Justice for All', 621, 9, '11/12/2003', 4, 2, 0, GETDATE(), ORIGINAL_LOGIN());

insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (1, 8, 1, 5, '10.00', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (2, 13, 13, 1, '11.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (3, 16, 1, 1, '14.25', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (4, 0, 3, 5, '3.00', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (5, 15, 6, 2, '1.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (6, 10, 14, 3, '13.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (7, 6, 4, 3, '2.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (8, 16, 3, 3, '7.00', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (9, 0, 20, 2, '5.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (10, 15, 16, 1, '23.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (11, 6, 9, 1, '20.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (12, 17, 10, 3, '7.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (13, 18, 12, 4, '15.00', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (14, 7, 5, 1, '18.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (15, 5, 4, 1, '7.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (16, 4, 3, 5, '23.00', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (17, 16, 2, 3, '3.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (18, 14, 12, 5, '24.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (19, 19, 12, 1, '23.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (20, 6, 5, 1, '13.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (21, 12, 5, 2, '9.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (22, 18, 3, 2, '23.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (23, 17, 14, 4, '9.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (24, 9, 1, 2, '17.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (25, 20, 5, 3, '3.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (26, 4, 9, 4, '1.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (27, 9, 12, 5, '22.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (28, 11, 6, 2, '21.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (29, 2, 20, 2, '14.99', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (30, 0, 16, 2, '8.00', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (31, 15, 12, 1, '17.09', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (32, 2, 17, 5, '11.64', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (33, 0, 14, 4, '11.77', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (34, 17, 4, 2, '3.06', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (35, 20, 5, 3, '15.22', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (36, 14, 14, 4, '4.63', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (37, 8, 8, 1, '24.81', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (38, 4, 6, 1, '3.66', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (39, 1, 12, 2, '24.65', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (40, 11, 0, 1, '5.49', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (41, 19, 11, 3, '18.86', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (42, 7, 10, 5, '18.67', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (43, 3, 3, 2, '9.92', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (44, 15, 0, 4, '19.55', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (45, 12, 9, 2, '10.15', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (46, 20, 9, 2, '15.84', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (47, 5, 0, 3, '22.50', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (48, 5, 18, 4, '23.62', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (49, 12, 2, 1, '16.28', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (50, 14, 0, 5, '22.48', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (51, 6, 12, 3, '9.85', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (52, 9, 0, 5, '14.59', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (53, 8, 18, 1, '23.35', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (54, 12, 10, 1, '14.66', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (55, 7, 17, 5, '17.39', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (56, 19, 5, 3, '5.66', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (57, 5, 15, 4, '23.01', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (58, 1, 6, 2, '24.07', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (59, 8, 19, 3, '15.66', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (60, 8, 1, 4, '2.57', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (61, 8, 17, 2, '2.69', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (62, 3, 9, 4, '18.84', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (63, 10, 12, 4, '6.80', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (64, 13, 6, 1, '23.40', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (65, 15, 8, 3, '3.56', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (66, 12, 6, 5, '22.71', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (67, 4, 10, 2, '9.35', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (68, 12, 11, 3, '11.76', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (69, 11, 3, 3, '18.59', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (70, 11, 11, 5, '24.77', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (71, 12, 8, 3, '11.08', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (72, 18, 16, 1, '6.71', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (73, 9, 18, 2, '16.90', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (74, 2, 9, 2, '22.16', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (75, 3, 8, 3, '9.75', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (76, 6, 16, 3, '9.26', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (77, 20, 0, 2, '16.48', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (78, 6, 15, 3, '22.25', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (79, 19, 12, 2, '7.62', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (80, 12, 11, 2, '18.28', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (81, 3, 9, 4, '17.93', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (82, 3, 1, 4, '15.34', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (83, 3, 8, 2, '4.30', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (84, 8, 6, 5, '5.67', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (85, 4, 4, 1, '3.26', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (86, 1, 20, 4, '11.82', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (87, 6, 13, 4, '1.56', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (88, 4, 5, 1, '3.02', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (89, 14, 1, 2, '13.48', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (90, 5, 5, 3, '16.07', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (91, 3, 14, 1, '18.91', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (92, 17, 1, 5, '19.43', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (93, 12, 7, 3, '12.60', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (94, 15, 1, 3, '21.08', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (95, 10, 14, 1, '6.51', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (96, 20, 10, 4, '19.08', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (97, 18, 20, 2, '2.16', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (98, 7, 10, 5, '19.54', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (99, 5, 7, 1, '1.43', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (100, 19, 18, 5, '21.91', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (101, 5, 12, 5, '21.10', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (102, 11, 20, 4, '19.56', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (103, 6, 13, 4, '10.13', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (104, 2, 2, 5, '11.52', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (105, 9, 5, 2, '11.92', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (106, 8, 15, 3, '9.51', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (107, 6, 5, 4, '3.63', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (108, 17, 11, 4, '18.32', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (109, 6, 4, 2, '8.90', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (110, 19, 9, 1, '13.56', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (111, 6, 16, 3, '22.05', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (112, 16, 17, 1, '17.10', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (113, 16, 1, 5, '7.52', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (114, 3, 16, 1, '15.59', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (115, 20, 1, 3, '18.22', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (116, 6, 13, 5, '24.45', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (117, 11, 8, 3, '1.15', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (118, 0, 16, 3, '15.48', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (119, 7, 9, 1, '23.85', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (120, 1, 17, 2, '3.03', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (121, 7, 8, 5, '2.65', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (122, 15, 0, 5, '11.88', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (123, 1, 14, 5, '13.28', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (124, 0, 0, 5, '22.23', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (125, 10, 5, 4, '17.90', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (126, 12, 11, 4, '18.24', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (127, 1, 11, 5, '11.81', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (128, 18, 7, 1, '21.75', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (129, 4, 18, 5, '19.00', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (130, 4, 2, 2, '8.35', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (131, 15, 18, 2, '7.96', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (132, 13, 1, 3, '18.33', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (133, 3, 9, 1, '2.11', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (134, 6, 7, 4, '14.69', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (135, 20, 6, 1, '7.35', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (136, 11, 6, 5, '22.31', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (137, 7, 7, 4, '10.34', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (138, 19, 13, 5, '7.67', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (139, 14, 1, 2, '20.16', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (140, 9, 19, 2, '7.38', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (141, 3, 2, 1, '10.39', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (142, 5, 20, 4, '21.92', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (143, 16, 9, 2, '9.96', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (144, 18, 6, 2, '5.71', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (145, 9, 16, 4, '21.73', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (146, 15, 12, 3, '14.00', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (147, 19, 1, 4, '14.11', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (148, 0, 12, 4, '16.13', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (149, 6, 0, 1, '21.54', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (150, 6, 0, 2, '11.79', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (151, 6, 7, 4, '6.35', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (152, 20, 13, 2, '13.76', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (153, 2, 11, 3, '1.61', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (154, 5, 2, 4, '23.61', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (155, 20, 1, 4, '10.61', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (156, 12, 7, 4, '21.84', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (157, 18, 14, 5, '18.96', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (158, 0, 15, 2, '12.09', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (159, 18, 6, 4, '4.40', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (160, 20, 7, 5, '3.65', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (161, 13, 8, 5, '7.76', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (162, 5, 19, 1, '19.12', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (163, 16, 16, 4, '6.87', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (164, 16, 8, 4, '17.38', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (165, 4, 4, 1, '23.40', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (166, 6, 20, 4, '11.58', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (167, 17, 0, 3, '8.74', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (168, 11, 20, 2, '20.96', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (169, 15, 5, 4, '17.01', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (170, 5, 13, 4, '23.45', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (171, 19, 17, 2, '4.83', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (172, 6, 4, 1, '2.26', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (173, 15, 2, 2, '19.39', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (174, 5, 19, 5, '23.24', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (175, 15, 18, 4, '4.40', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (176, 11, 17, 3, '15.72', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (177, 2, 7, 1, '23.03', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (178, 3, 18, 2, '24.91', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (179, 12, 8, 4, '9.11', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (180, 1, 16, 5, '6.69', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (181, 7, 1, 2, '14.05', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (182, 10, 7, 1, '19.12', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (183, 20, 12, 5, '18.32', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (184, 1, 6, 4, '6.07', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (185, 7, 2, 4, '23.58', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (186, 5, 14, 5, '8.78', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (187, 8, 4, 1, '8.41', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (188, 18, 1, 3, '13.03', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (189, 14, 3, 2, '10.21', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (190, 11, 8, 4, '8.01', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (191, 6, 11, 3, '1.05', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (192, 17, 5, 4, '18.33', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (193, 8, 15, 3, '11.12', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (194, 15, 1, 1, '8.67', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (195, 0, 6, 1, '14.89', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (196, 17, 1, 2, '7.59', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (197, 3, 20, 1, '2.76', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (198, 17, 3, 1, '1.39', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (199, 20, 13, 3, '2.82', GETDATE(), ORIGINAL_LOGIN());
insert into PubInventory (PubID, UnitsIn, UnitsOut, Shelved, UnitPrice, ModifiedDate, ModifiedBy) values (200, 12, 12, 3, '8.38', GETDATE(), ORIGINAL_LOGIN());


insert into Suppliers (  CompanyName, AddressID, ActiveFlag, ContactID, ContactTitle, ModifiedDate, ModifiedBy) values ( 'Windler Group', 17, 0, 20, 'Computer Systems Analyst IV', GETDATE(), ORIGINAL_LOGIN());
insert into Suppliers (  CompanyName, AddressID, ActiveFlag, ContactID, ContactTitle, ModifiedDate, ModifiedBy) values ( 'Franecki, Funk and Carter', 46, 1, 58, 'Associate Professor', GETDATE(), ORIGINAL_LOGIN());
insert into Suppliers (  CompanyName, AddressID, ActiveFlag, ContactID, ContactTitle, ModifiedDate, ModifiedBy) values ( 'Dickinson Inc', 47, 1, 59, 'Payment Adjustment Coordinator', GETDATE(), ORIGINAL_LOGIN());
insert into Suppliers (  CompanyName, AddressID, ActiveFlag, ContactID, ContactTitle, ModifiedDate, ModifiedBy) values ( 'Hirthe-Labadie', 48, 1, 60, 'VP of Sales', GETDATE(), ORIGINAL_LOGIN());
insert into Suppliers (  CompanyName, AddressID, ActiveFlag, ContactID, ContactTitle, ModifiedDate, ModifiedBy) values ( 'Schowalter-Kirlin', 49, 1, 61, null, GETDATE(), ORIGINAL_LOGIN());
insert into Suppliers (  CompanyName, AddressID, ActiveFlag, ContactID, ContactTitle, ModifiedDate, ModifiedBy) values ( 'Halvorson Group', 50, 1, 62, 'Librarian', GETDATE(), ORIGINAL_LOGIN());
insert into Suppliers (  CompanyName, AddressID, ActiveFlag, ContactID, ContactTitle, ModifiedDate, ModifiedBy) values ( 'Littel-Mosciski', 51, 1, 63, 'Editor', GETDATE(), ORIGINAL_LOGIN());
insert into Suppliers (  CompanyName, AddressID, ActiveFlag, ContactID, ContactTitle, ModifiedDate, ModifiedBy) values ( 'Schultz, Pfannerstill and Mohr', 52, 1, 64, 'Sales Associate', GETDATE(), ORIGINAL_LOGIN());
insert into Suppliers (  CompanyName, AddressID, ActiveFlag, ContactID, ContactTitle, ModifiedDate, ModifiedBy) values ( 'O''Connell Group', 53, 1, 65, 'Associate Professor', GETDATE(), ORIGINAL_LOGIN());

INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (3, '09/19/2017', '10/07/2017' , '10/19/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (5, '09/19/2017', '10/19/2017', '10/19/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (6, '09/19/2017','10/12/2017' , '10/19/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (7, '09/20/2017', '10/25/2017', '10/20/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (8, '09/20/2017', '10/20/2017', '10/20/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (12, '09/21/2017', '10/01/2017' , '10/21/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (13, '09/21/2017', NULL , '10/21/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (15, '09/22/2017', '09/24/2017', '10/22/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (21, '09/24/2017', '10/10/2017', '10/24/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (22, '09/24/2017', '10/26/2017', '10/24/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (24, '09/25/2017', '10/16/2017', '10/25/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (25, '09/25/2017', '10/25/2017', '10/25/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (26, '09/25/2017', '10/30/2017', '10/25/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (28, '09/26/2017', '10/15/2017', '10/26/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (29, '09/26/2017', '10/08/2017', '10/26/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (30, '09/26/2017', '10/04/2017', '10/26/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (31, '09/26/2017', '10/27/2017', '10/26/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (32, '09/26/2017', '10/22/2017', '10/26/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (33, '09/27/2017', '10/30/2017', '10/27/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (34, '09/27/2017', '11/01/2017', '10/27/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (39, '09/30/2017', '10/19/2017', '10/30/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (42, '09/30/2017', '10/22/2017', '10/30/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (12, '10/01/2017', '10/15/2017', '11/01/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (43, '10/01/2017', NULL, '11/01/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (45, '10/01/2017', '10/22/2017', '11/01/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (46, '10/02/2017', '10/30/2017', '11/02/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (47, '10/02/2017', NULL, '11/02/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (51, '10/03/2017', '11/03/2017', '11/03/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (5, '10/03/2017', '11/14/2017' , '11/03/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (52, '10/05/2017', '10/23/2017', '11/05/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (53, '10/05/2017', '11/03/2017', '11/05/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (54, '10/05/2017', '10/20/2017', '11/05/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (55, '10/06/2017', '11/01/2017', '11/06/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (56, '10/07/2017', '11/05/2017', '11/07/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (57, '10/07/2017', '10/14/2017', '11/07/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (8, '10/08/2017', '10/29/2017', '11/08/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (3, '10/08/2017', '11/01/2017', '11/08/2017', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (30, '10/08/2017', NULL, '04/08/2018', GETDATE(), ORIGINAL_LOGIN())
INSERT INTO PubTracking (CustID, OutDate, InDate, DueDate, ModifiedDate, ModifiedBy) VALUES (15, '10/09/2017', '11/07/2017', '11/09/2017', GETDATE(), ORIGINAL_LOGIN())

INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (1, 41, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (1, 165, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (2, 175, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (3, 119, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (3, 177, 2, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (4, 96, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (5, 83, 2, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (6, 2, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (7, 199, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (8, 153, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (8, 174, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (9, 146, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (10, 46, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (10, 49, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (10, 182, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (11, 96, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (12, 32, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (13, 142, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (14, 147, 2, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (15, 9, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (16, 163, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (17, 180, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (18, 85, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (18, 18, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (18, 174, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (19, 92, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (20, 6, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (21, 193, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (22, 76, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (23, 83, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (24, 157, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (25, 163, 2, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (26, 166, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (26, 170, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (27, 23, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (28, 136, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (29, 2, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (29, 112, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (30, 44, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (31, 31, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (32, 9, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (33, 78, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (34, 152, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (34, 68, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (34, 57, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (35, 135, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (36, 195, 2, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (37, 68, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (37, 43, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (37, 84, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (38, 2, 1, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO TrackingDetails (TrackID, PubID, Quantity, ModifiedDate, ModifiedBy) VALUES (39, 8, 1, GETDATE(), ORIGINAL_LOGIN())



insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/21/2017', '9/11/2017', 1, '71.94', '8.93', '18.80', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/25/2017', '9/10/2017', 1, '66.66', '14.30', '7.07', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/6/2017', '9/16/2017', 0, '117.94', '32.65', '43.04', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '11/5/2017', '11/12/2017', 1, '492.66', '14.55', '24.66', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '9/4/2017', '10/5/2017', 0, '178.94', '34.53', '15.39', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/30/2017', '10/20/2017', 0, '218.69', '19.56', '28.03', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '9/6/2017', '11/14/2017', 1, '55.88', '25.97', '22.29', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '9/8/2017', '9/27/2017', 0, '486.91', '39.22', '48.71', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/10/2017', '10/2/2017', 0, '312.20', '14.79', '28.18', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/13/2017', '10/3/2017', 0, '253.01', '3.90', '32.01', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '9/27/2017', '10/17/2017', 1, '140.70', '3.37', '20.03', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/3/2017', '9/13/2017', 1, '370.30', '8.29', '10.44', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '10/6/2017', '10/7/2017', 1, '142.31', '23.94', '39.37', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '11/1/2017', '10/24/2017', 0, '147.24', '44.09', '11.88', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/13/2017', '11/5/2017', 0, '70.43', '15.64', '30.39', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/28/2017', '10/15/2017', 1, '480.13', '39.24', '12.52', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '11/8/2017', '11/6/2017', 0, '188.30', '32.72', '11.95', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/27/2017', '11/4/2017', 0, '489.56', '39.57', '49.03', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/30/2017', '11/9/2017', 0, '12.48', '18.90', '44.18', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '11/8/2017', '9/14/2017', 0, '330.20', '6.85', '26.56', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '10/8/2017', '10/13/2017', 0, '497.09', '14.72', '32.60', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/27/2017', '10/31/2017', 1, '412.08', '43.86', '44.16', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/26/2017', '9/14/2017', 0, '444.75', '31.50', '8.67', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/16/2017', '9/11/2017', 1, '121.23', '30.11', '11.30', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/6/2017', '10/6/2017', 0, '324.75', '32.33', '25.61', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/15/2017', '9/22/2017', 0, '63.69', '27.35', '43.77', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/22/2017', '10/9/2017', 1, '212.31', '31.73', '46.99', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/12/2017', '10/17/2017', 1, '218.67', '34.81', '41.30', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/17/2017', '9/16/2017', 0, '318.28', '29.58', '23.07', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/28/2017', '9/9/2017', 0, '290.50', '6.43', '23.59', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '9/5/2017', '9/15/2017', 0, '6.67', '15.31', '12.77', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/28/2017', '9/25/2017', 0, '379.12', '28.04', '46.92', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/18/2017', '10/27/2017', 1, '379.50', '27.90', '6.33', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '10/21/2017', '10/7/2017', 0, '447.93', '23.26', '14.38', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '9/22/2017', '10/21/2017', 1, '252.23', '30.51', '18.61', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/18/2017', '10/2/2017', 0, '160.37', '21.74', '26.13', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/19/2017', '10/7/2017', 0, '364.46', '28.63', '11.85', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/13/2017', '10/3/2017', 1, '51.99', '27.72', '24.76', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/23/2017', '11/3/2017', 0, '418.06', '30.53', '12.72', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '10/2/2017', '9/21/2017', 1, '443.30', '38.16', '49.81', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '9/22/2017', '9/13/2017', 1, '110.46', '8.35', '45.88', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/20/2017', '11/9/2017', 0, '327.48', '13.75', '11.81', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '11/8/2017', '9/14/2017', 0, '66.48', '20.97', '4.73', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '9/13/2017', '9/18/2017', 1, '192.69', '40.29', '47.24', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '9/4/2017', '11/3/2017', 1, '477.31', '12.87', '42.85', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '10/27/2017', '10/16/2017', 1, '58.71', '37.44', '12.05', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/24/2017', '9/29/2017', 0, '34.62', '40.99', '27.06', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '10/13/2017', '11/5/2017', 1, '247.81', '38.59', '4.35', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/21/2017', '10/9/2017', 1, '56.42', '30.29', '31.04', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/28/2017', '10/11/2017', 1, '368.68', '19.14', '3.24', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/25/2017', '10/25/2017', 1, '233.03', '42.42', '40.76', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/17/2017', '9/11/2017', 0, '136.20', '11.60', '17.85', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '11/7/2017', '10/7/2017', 1, '151.47', '15.24', '45.80', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '9/5/2017', '9/22/2017', 0, '370.69', '21.76', '3.84', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/20/2017', '10/21/2017', 0, '375.55', '40.07', '29.98', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/14/2017', '10/21/2017', 1, '419.28', '9.74', '10.23', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/20/2017', '9/19/2017', 0, '110.27', '5.56', '49.13', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '11/1/2017', '10/12/2017', 0, '406.46', '24.36', '11.21', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/19/2017', '9/26/2017', 0, '359.98', '9.62', '10.91', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/19/2017', '10/25/2017', 1, '115.55', '3.69', '26.99', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/22/2017', '10/13/2017', 0, '74.95', '13.25', '27.10', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/1/2017', '10/20/2017', 0, '8.20', '12.78', '27.09', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/16/2017', '9/11/2017', 0, '63.00', '33.78', '26.90', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/2/2017', '11/6/2017', 0, '356.31', '12.96', '46.25', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/4/2017', '10/22/2017', 1, '393.56', '33.76', '4.16', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/3/2017', '9/26/2017', 0, '364.26', '5.05', '41.34', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/12/2017', '10/22/2017', 1, '440.24', '34.56', '28.27', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/28/2017', '9/11/2017', 0, '478.91', '29.83', '5.58', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '11/7/2017', '10/17/2017', 1, '152.86', '9.32', '34.83', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/14/2017', '10/7/2017', 1, '426.98', '14.05', '38.40', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/6/2017', '10/31/2017', 1, '340.72', '40.45', '47.88', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/31/2017', '10/29/2017', 1, '125.35', '24.80', '49.87', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/20/2017', '10/15/2017', 0, '36.31', '23.01', '19.10', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/14/2017', '10/30/2017', 1, '447.39', '24.07', '38.67', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/8/2017', '10/19/2017', 1, '162.19', '4.78', '42.56', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '11/8/2017', '9/21/2017', 1, '94.03', '22.65', '2.12', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/9/2017', '9/16/2017', 1, '375.04', '37.03', '26.63', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/9/2017', '11/6/2017', 1, '177.49', '19.99', '44.76', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/21/2017', '10/31/2017', 0, '409.40', '29.21', '48.84', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/19/2017', '11/3/2017', 0, '273.67', '23.84', '5.87', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/21/2017', '9/16/2017', 1, '268.41', '18.37', '16.60', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/27/2017', '9/13/2017', 1, '144.46', '27.37', '44.95', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '11/1/2017', '10/8/2017', 0, '436.56', '44.10', '41.05', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/22/2017', '10/25/2017', 1, '439.99', '31.87', '24.94', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/29/2017', '11/1/2017', 0, '86.59', '15.63', '34.63', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '9/20/2017', '11/13/2017', 1, '146.13', '31.34', '2.52', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '11/3/2017', '10/10/2017', 1, '88.95', '34.36', '32.07', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/10/2017', '11/14/2017', 0, '478.54', '31.11', '15.12', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/22/2017', '10/20/2017', 1, '460.49', '34.14', '45.46', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/23/2017', '9/23/2017', 0, '101.64', '12.93', '18.57', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/23/2017', '10/23/2017', 0, '286.56', '27.39', '41.75', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/27/2017', '10/5/2017', 0, '26.08', '32.01', '18.64', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/6/2017', '10/12/2017', 1, '199.62', '39.32', '36.69', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/24/2017', '9/29/2017', 1, '464.42', '7.03', '38.05', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/13/2017', '11/7/2017', 0, '199.02', '5.79', '16.89', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/19/2017', '11/5/2017', 1, '51.49', '23.30', '34.53', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/26/2017', '9/17/2017', 1, '23.53', '16.21', '13.08', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/8/2017', '9/13/2017', 0, '448.40', '10.64', '12.51', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/25/2017', '9/23/2017', 0, '168.67', '15.24', '47.84', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/8/2017', '9/18/2017', 0, '90.67', '14.61', '21.19', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/7/2017', '10/7/2017', 0, '444.14', '39.17', '21.20', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '9/17/2017', '9/17/2017', 0, '73.98', '40.38', '44.75', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '10/12/2017', '9/23/2017', 0, '473.85', '43.16', '43.85', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/19/2017', '9/20/2017', 0, '269.55', '39.05', '47.27', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/10/2017', '11/13/2017', 1, '340.54', '6.30', '40.54', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/24/2017', '10/12/2017', 1, '438.18', '10.90', '38.10', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/28/2017', '11/13/2017', 0, '149.96', '40.99', '6.01', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '11/8/2017', '9/25/2017', 1, '33.90', '32.57', '34.40', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/7/2017', '10/6/2017', 0, '346.66', '36.40', '15.81', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/15/2017', '11/8/2017', 1, '243.48', '32.88', '37.83', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/25/2017', '11/14/2017', 1, '457.96', '43.80', '7.77', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '11/9/2017', '9/15/2017', 0, '133.03', '21.40', '8.83', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/16/2017', '10/7/2017', 0, '119.95', '6.27', '20.26', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '11/8/2017', '10/4/2017', 1, '464.77', '4.41', '5.03', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/7/2017', '9/23/2017', 1, '15.26', '39.71', '40.80', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '11/4/2017', '10/30/2017', 1, '458.00', '39.53', '9.97', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '9/26/2017', '9/20/2017', 1, '236.93', '15.74', '48.64', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/26/2017', '11/12/2017', 0, '27.72', '6.04', '23.22', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/23/2017', '10/17/2017', 1, '141.62', '21.02', '26.24', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/30/2017', '10/24/2017', 1, '397.11', '30.12', '2.01', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '9/24/2017', '11/2/2017', 0, '131.70', '18.17', '48.23', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/23/2017', '9/24/2017', 0, '487.80', '18.77', '30.91', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '9/15/2017', '9/13/2017', 0, '344.60', '17.87', '6.12', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/11/2017', '9/26/2017', 0, '225.94', '23.95', '32.40', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/20/2017', '9/10/2017', 0, '22.21', '28.68', '17.67', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/16/2017', '11/3/2017', 0, '177.85', '38.76', '26.63', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/23/2017', '10/14/2017', 0, '303.10', '11.17', '38.29', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '11/7/2017', '9/30/2017', 1, '165.91', '20.91', '14.68', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/5/2017', '11/8/2017', 0, '259.96', '44.47', '18.43', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '9/17/2017', '9/11/2017', 0, '137.58', '38.75', '10.89', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/15/2017', '11/13/2017', 1, '12.31', '34.36', '44.58', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/11/2017', '10/6/2017', 0, '187.53', '17.76', '10.86', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/22/2017', '11/2/2017', 0, '429.90', '32.66', '31.47', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/11/2017', '11/8/2017', 1, '496.84', '4.30', '7.09', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/12/2017', '11/12/2017', 1, '266.98', '19.46', '27.28', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/5/2017', '11/1/2017', 1, '60.73', '36.81', '20.89', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/24/2017', '10/18/2017', 1, '355.00', '11.37', '9.99', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/8/2017', '9/16/2017', 1, '114.55', '16.86', '40.73', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/19/2017', '10/18/2017', 0, '196.65', '35.36', '33.66', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/17/2017', '11/2/2017', 1, '270.30', '30.73', '16.74', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '10/23/2017', '10/23/2017', 0, '283.64', '20.52', '28.46', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/9/2017', '9/28/2017', 1, '72.42', '21.69', '12.09', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/2/2017', '11/8/2017', 1, '177.64', '35.03', '31.32', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/26/2017', '9/18/2017', 0, '435.77', '27.94', '11.16', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/17/2017', '10/29/2017', 0, '228.30', '32.69', '12.15', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/27/2017', '11/6/2017', 0, '490.56', '20.34', '34.92', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/20/2017', '10/7/2017', 0, '38.99', '38.67', '6.31', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/18/2017', '10/15/2017', 1, '432.46', '26.09', '14.35', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '11/5/2017', '10/22/2017', 1, '449.24', '8.01', '36.81', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/4/2017', '11/13/2017', 1, '224.36', '26.46', '46.28', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/16/2017', '9/17/2017', 0, '279.43', '18.96', '37.55', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/29/2017', '10/1/2017', 0, '262.72', '22.00', '26.93', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/29/2017', '10/15/2017', 1, '80.35', '17.74', '36.28', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/22/2017', '11/6/2017', 1, '403.09', '11.37', '19.52', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/26/2017', '10/15/2017', 1, '183.25', '33.96', '30.70', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/16/2017', '10/22/2017', 0, '22.47', '8.57', '4.28', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '9/11/2017', '11/1/2017', 1, '397.63', '10.23', '39.52', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/24/2017', '9/13/2017', 1, '6.21', '18.52', '38.43', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/29/2017', '9/29/2017', 1, '429.01', '13.43', '36.71', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '10/27/2017', '11/8/2017', 0, '456.98', '13.46', '35.36', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/10/2017', '9/29/2017', 0, '229.41', '18.99', '12.18', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '11/4/2017', '10/31/2017', 0, '5.61', '31.64', '8.51', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/19/2017', '9/26/2017', 0, '176.90', '5.97', '14.45', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/12/2017', '10/19/2017', 1, '82.93', '18.54', '9.26', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/20/2017', '11/8/2017', 0, '302.04', '26.52', '38.90', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '11/7/2017', '11/11/2017', 1, '23.25', '35.60', '23.81', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '11/8/2017', '9/28/2017', 1, '79.02', '17.45', '25.70', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/25/2017', '10/4/2017', 1, '6.68', '15.56', '39.54', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/29/2017', '9/14/2017', 1, '420.04', '36.79', '12.33', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '11/7/2017', '10/5/2017', 1, '200.37', '22.21', '18.71', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/4/2017', '11/1/2017', 1, '91.04', '10.97', '16.95', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/23/2017', '9/17/2017', 1, '369.66', '38.64', '11.47', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/25/2017', '10/20/2017', 1, '408.01', '43.11', '20.42', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '11/7/2017', '9/9/2017', 0, '279.80', '8.63', '48.24', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/21/2017', '9/27/2017', 1, '288.85', '36.94', '2.38', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/12/2017', '10/10/2017', 1, '448.08', '35.75', '23.21', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '11/1/2017', '10/12/2017', 1, '466.39', '23.64', '8.56', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/17/2017', '10/16/2017', 1, '389.39', '14.76', '25.97', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '9/4/2017', '10/5/2017', 0, '83.79', '36.00', '4.76', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/23/2017', '10/28/2017', 1, '470.76', '44.88', '36.17', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '11/2/2017', '9/12/2017', 0, '326.92', '44.70', '7.94', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '11/1/2017', '10/8/2017', 1, '496.69', '32.57', '47.33', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '11/7/2017', '11/10/2017', 1, '397.33', '12.20', '41.91', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/10/2017', '9/19/2017', 0, '129.62', '27.73', '22.81', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/28/2017', '11/12/2017', 1, '253.44', '32.77', '22.25', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/16/2017', '11/10/2017', 0, '31.12', '36.69', '28.46', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/26/2017', '11/8/2017', 1, '120.89', '13.92', '46.93', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/15/2017', '9/10/2017', 0, '157.85', '40.07', '41.33', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '10/21/2017', '10/4/2017', 0, '45.21', '14.64', '23.12', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '11/2/2017', '10/24/2017', 0, '217.89', '30.69', '38.70', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/15/2017', '11/14/2017', 0, '436.27', '29.78', '35.64', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/15/2017', '10/6/2017', 1, '281.07', '24.62', '8.03', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '9/4/2017', '10/22/2017', 0, '121.19', '16.90', '13.07', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '11/5/2017', '11/10/2017', 1, '353.24', '6.74', '45.61', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '11/7/2017', '9/28/2017', 0, '33.22', '23.84', '37.56', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/15/2017', '10/12/2017', 0, '48.79', '41.66', '27.54', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '11/5/2017', '10/12/2017', 1, '340.43', '31.57', '21.72', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '11/2/2017', '10/7/2017', 0, '15.30', '34.52', '19.54', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/4/2017', '9/27/2017', 0, '248.49', '30.88', '12.36', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/24/2017', '10/12/2017', 1, '36.91', '7.41', '36.01', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '9/28/2017', '9/11/2017', 0, '460.95', '35.66', '48.88', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '10/9/2017', '10/27/2017', 1, '183.25', '26.85', '19.28', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/31/2017', '9/27/2017', 0, '164.27', '23.85', '3.09', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/25/2017', '9/21/2017', 1, '290.03', '4.39', '48.16', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '10/25/2017', '10/23/2017', 1, '70.16', '16.17', '17.66', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '9/28/2017', '10/18/2017', 1, '147.84', '22.22', '39.81', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '11/8/2017', '11/13/2017', 1, '216.24', '32.57', '17.27', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '11/8/2017', '9/13/2017', 0, '203.05', '35.97', '14.45', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '9/27/2017', '9/28/2017', 1, '453.62', '12.94', '12.54', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/26/2017', '9/13/2017', 0, '468.33', '28.48', '29.09', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/17/2017', '9/23/2017', 0, '61.42', '35.47', '19.83', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/18/2017', '10/13/2017', 1, '150.33', '39.65', '28.11', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '11/4/2017', '10/24/2017', 1, '384.72', '17.71', '39.84', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/21/2017', '10/23/2017', 1, '435.58', '7.52', '41.79', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/25/2017', '11/10/2017', 0, '280.58', '36.13', '20.38', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '11/6/2017', '9/21/2017', 1, '427.09', '16.09', '2.42', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/11/2017', '10/1/2017', 0, '40.64', '13.20', '32.62', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/13/2017', '9/20/2017', 0, '309.79', '23.20', '10.69', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/4/2017', '10/11/2017', 0, '150.65', '23.39', '20.44', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/19/2017', '9/27/2017', 1, '348.34', '21.97', '49.22', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/21/2017', '11/8/2017', 1, '365.28', '39.27', '9.79', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/4/2017', '10/8/2017', 1, '388.82', '10.48', '42.99', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/4/2017', '10/8/2017', 0, '84.68', '8.56', '42.57', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/6/2017', '10/2/2017', 0, '130.08', '33.32', '2.46', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/28/2017', '10/12/2017', 0, '102.84', '23.49', '43.39', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '10/13/2017', '11/4/2017', 1, '183.78', '26.18', '11.26', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '10/22/2017', '10/26/2017', 0, '52.72', '15.90', '36.74', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '10/7/2017', '10/26/2017', 0, '209.80', '6.68', '16.06', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '11/8/2017', '9/10/2017', 1, '21.39', '28.87', '37.88', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/7/2017', '10/21/2017', 1, '393.14', '31.50', '37.23', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '9/19/2017', '11/11/2017', 1, '289.72', '14.41', '11.66', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/30/2017', '10/16/2017', 0, '178.84', '4.03', '15.91', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (5, '11/6/2017', '10/24/2017', 1, '403.97', '11.69', '7.24', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/11/2017', '9/14/2017', 1, '416.31', '9.20', '4.39', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (9, '9/18/2017', '9/21/2017', 1, '209.55', '29.31', '26.50', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/12/2017', '9/26/2017', 0, '415.51', '26.23', '11.84', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '9/11/2017', '10/10/2017', 0, '33.42', '41.80', '9.63', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '9/11/2017', '9/21/2017', 0, '32.39', '13.84', '7.56', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '10/31/2017', '9/25/2017', 1, '296.60', '19.92', '19.67', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (6, '10/30/2017', '10/20/2017', 0, '27.16', '7.58', '28.65', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (7, '10/22/2017', '9/16/2017', 1, '320.94', '21.24', '32.87', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (1, '10/18/2017', '10/31/2017', 1, '13.92', '33.32', '45.65', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '10/7/2017', '9/23/2017', 1, '447.28', '13.73', '45.31', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/16/2017', '10/31/2017', 0, '145.10', '13.33', '30.66', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '9/20/2017', '11/13/2017', 1, '149.91', '20.51', '19.56', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (3, '10/23/2017', '10/15/2017', 1, '305.23', '23.09', '37.37', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (2, '10/11/2017', '9/24/2017', 1, '446.32', '6.97', '46.17', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/20/2017', '10/4/2017', 1, '332.76', '17.70', '28.35', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (8, '9/28/2017', '9/16/2017', 1, '9.63', '18.37', '3.96', GETDATE(), ORIGINAL_LOGIN());
insert into Orders (SupplierID, OrderDate, ShipDate, Status, SubTotal, Tax, Shipping, ModifiedDate, ModifiedBy) values (4, '10/13/2017', '11/10/2017', 1, '315.89', '4.03', '46.76', GETDATE(), ORIGINAL_LOGIN());


insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (1, 21, 27, 12, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (1, 81, 34, 39, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (2, 45, 46, 38, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (2, 195, 24, 25, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (3, 103, 24, 41, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (4, 56, 28, 12, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (5, 47, 39, 19, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (6, 77, 46, 37, 21, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (7, 189, 5, 9, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (8, 160, 50, 28, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (9, 129, 32, 44, 19, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (10, 132, 6, 7, 23, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (11, 81, 9, 42, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (11, 94, 48, 27, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (12, 43, 30, 46, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (13, 192, 17, 40, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (14, 168, 33, 43, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (15, 99, 37, 2, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (15, 147, 28, 6, 13, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (16, 25, 46, 32, 19, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (17, 20, 3, 50, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (18, 105, 32, 27, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (19, 80, 44, 1, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (20, 8, 22, 23, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (21, 191, 7, 33, 22, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (22, 18, 50, 26, 5, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (23, 83, 46, 7, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (24, 35, 5, 38, 14, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (25, 129, 46, 45, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (26, 129, 46, 17, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (27, 106, 9, 25, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (28, 146, 43, 19, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (29, 99, 16, 32, 5, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (29, 192, 21, 16, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (30, 185, 18, 42, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (30, 189, 17, 7, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (31, 153, 21, 3, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (32, 159, 42, 18, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (33, 101, 30, 23, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (34, 81, 24, 28, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (35, 49, 15, 36, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (36, 1, 35, 38, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (37, 30, 25, 23, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (38, 87, 44, 28, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (39, 138, 4, 11, 13, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (39, 37, 28, 19, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (40, 131, 31, 26, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (41, 100, 22, 19, 3, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (42, 16, 12, 1, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (43, 128, 48, 37, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (44, 132, 10, 50, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (45, 120, 43, 35, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (46, 183, 39, 16, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (47, 105, 50, 41, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (48, 93, 48, 3, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (49, 169, 22, 34, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (50, 141, 17, 33, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (51, 151, 17, 39, 21, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (52, 185, 7, 40, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (53, 80, 28, 9, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (54, 77, 17, 43, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (55, 89, 47, 28, 24, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (56, 4, 11, 46, 5, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (57, 108, 35, 5, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (58, 130, 6, 6, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (59, 17, 37, 9, 24, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (60, 167, 5, 35, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (61, 104, 36, 27, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (62, 174, 46, 28, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (63, 35, 10, 26, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (64, 196, 3, 6, 14, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (65, 23, 28, 31, 21, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (66, 57, 23, 36, 5, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (67, 113, 22, 29, 22, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (68, 88, 8, 30, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (69, 198, 30, 26, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (70, 86, 3, 7, 3, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (71, 127, 34, 16, 24, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (72, 25, 24, 2, 13, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (73, 189, 8, 12, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (74, 68, 29, 6, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (75, 110, 7, 17, 22, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (76, 2, 19, 4, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (77, 162, 14, 21, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (78, 30, 40, 4, 3, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (79, 115, 11, 30, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (80, 15, 45, 27, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (81, 190, 8, 14, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (82, 63, 37, 43, 21, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (83, 53, 46, 41, 3, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (84, 77, 6, 31, 13, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (85, 96, 49, 4, 19, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (86, 2, 21, 12, 3, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (87, 56, 45, 22, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (87, 111, 4, 3, 13, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (87, 200, 11, 7, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (88, 129, 11, 35, 23, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (88, 184, 15, 35, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (89, 32, 29, 48, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (90, 191, 37, 11, 18, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (91, 159, 34, 37, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (92, 98, 19, 12, 23, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (93, 76, 47, 34, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (94, 1, 35, 40, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (95, 8, 32, 3, 22, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (96, 16, 25, 21, 5, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (97, 97, 39, 36, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (98, 128, 36, 18, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (99, 160, 33, 19, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (99, 53, 30, 42, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (100, 36, 14, 30, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (101, 113, 1, 44, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (102, 36, 43, 48, 18, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (103, 23, 21, 34, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (104, 139, 37, 38, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (104, 198, 29, 41, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (105, 91, 24, 1, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (105, 155, 47, 7, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (106, 81, 49, 14, 24, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (107, 194, 28, 21, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (108, 4, 25, 3, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (109, 57, 30, 30, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (110, 50, 22, 49, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (111, 133, 33, 13, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (112, 150, 1, 18, 21, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (113, 123, 13, 31, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (114, 60, 33, 4, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (115, 30, 25, 42, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (116, 77, 40, 46, 23, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (117, 9, 12, 19, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (118, 153, 26, 21, 22, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (119, 24, 3, 4, 24, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (120, 164, 27, 47, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (121, 14, 11, 5, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (123, 36, 12, 30, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (124, 195, 7, 13, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (125, 69, 30, 26, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (126, 182, 47, 11, 5, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (127, 163, 50, 3, 13, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (128, 170, 5, 38, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (129, 36, 6, 3, 23, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (130, 99, 26, 2, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (131, 112, 27, 35, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (132, 119, 11, 34, 13, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (133, 110, 8, 46, 19, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (134, 131, 39, 10, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (135, 186, 10, 39, 22, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (136, 36, 10, 8, 18, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (137, 147, 11, 34, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (138, 157, 6, 43, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (139, 170, 25, 36, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (140, 144, 11, 39, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (141, 58, 47, 5, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (142, 28, 13, 6, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (143, 70, 21, 14, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (144, 179, 28, 8, 22, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (145, 35, 40, 48, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (146, 178, 2, 46, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (146, 16, 45, 19, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (147, 6, 30, 28, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (148, 111, 23, 4, 21, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (149, 165, 9, 5, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (150, 190, 33, 7, 23, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (151, 152, 9, 26, 0, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (152, 129, 12, 3, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (153, 31, 4, 31, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (154, 113, 47, 15, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (155, 75, 16, 15, 24, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (155, 1, 38, 34, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (156, 178, 11, 26, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (157, 33, 27, 16, 3, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (158, 3, 34, 23, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (159, 156, 13, 19, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (160, 175, 28, 10, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (161, 119, 31, 1, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (161, 132, 32, 48, 9, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (162, 51, 39, 17, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (163, 180, 33, 38, 18, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (164, 188, 35, 28, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (165, 168, 18, 6, 13, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (166, 24, 44, 47, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (167, 47, 30, 25, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (167, 193, 37, 16, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (168, 68, 25, 24, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (169, 2, 36, 16, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (170, 169, 22, 6, 3, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (171, 52, 49, 24, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (172, 106, 32, 30, 23, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (173, 154, 48, 29, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (173, 177, 19, 41, 24, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (174, 172, 3, 37, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (175, 63, 27, 9, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (176, 187, 45, 13, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (177, 31, 6, 41, 22, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (177, 156, 8, 26, 18, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (178, 129, 21, 43, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (179, 170, 22, 16, 5, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (180, 173, 12, 7, 22, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (181, 191, 4, 38, 21, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (182, 55, 11, 31, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (182, 140, 32, 46, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (183, 3, 5, 9, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (184, 57, 37, 8, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (185, 87, 16, 48, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (186, 125, 31, 9, 14, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (187, 125, 29, 16, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (187, 138, 6, 36, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (188, 150, 1, 19, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (189, 33, 19, 32, 14, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (190, 16, 7, 10, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (191, 166, 12, 5, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (191, 27, 32, 1, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (192, 33, 21, 45, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (193, 156, 36, 44, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (193, 49, 2, 18, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (194, 71, 42, 38, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (195, 30, 44, 35, 18, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (196, 186, 23, 44, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (197, 80, 3, 32, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (198, 26, 6, 22, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (199, 199, 25, 42, 23, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (200, 35, 12, 31, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (201, 101, 28, 33, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (202, 19, 29, 35, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (203, 123, 22, 23, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (204, 147, 44, 6, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (205, 26, 44, 48, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (206, 1, 12, 16, 3, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (207, 95, 47, 14, 18, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (208, 39, 29, 17, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (209, 177, 5, 25, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (210, 46, 20, 9, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (211, 176, 4, 35, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (212, 113, 9, 36, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (213, 96, 34, 49, 24, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (214, 47, 41, 28, 18, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (215, 117, 39, 3, 21, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (216, 89, 41, 42, 20, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (217, 187, 44, 20, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (218, 185, 29, 23, 3, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (219, 102, 41, 49, 6, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (220, 95, 43, 37, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (221, 180, 40, 7, 4, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (221, 75, 13, 4, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (222, 34, 21, 13, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (223, 115, 22, 11, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (224, 96, 31, 32, 8, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (225, 96, 32, 27, 19, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (226, 95, 31, 45, 18, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (227, 157, 38, 22, 13, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (227, 150, 13, 20, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (228, 99, 41, 11, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (229, 88, 38, 33, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (229, 151, 2, 11, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (229, 112, 16, 26, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (230, 105, 21, 4, 2, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (231, 148, 5, 33, 17, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (232, 110, 27, 22, 19, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (233, 90, 6, 47, 21, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (234, 138, 30, 43, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (235, 100, 47, 41, 16, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (236, 173, 40, 46, 15, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (237, 38, 45, 26, 12, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (238, 94, 46, 5, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (239, 193, 20, 3, 24, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (240, 91, 11, 3, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (241, 199, 5, 27, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (241, 67, 43, 22, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (242, 34, 46, 29, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (243, 93, 18, 43, 23, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (244, 63, 40, 13, 7, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (245, 97, 25, 17, 25, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (246, 9, 35, 35, 14, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (247, 155, 12, 27, 5, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (248, 98, 36, 9, 11, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (249, 72, 20, 14, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (249, 156, 4, 7, 10, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (250, 149, 27, 46, 1, GETDATE(), ORIGINAL_LOGIN());
insert into OrderDetails (OrderID, PubID, OrderQty, ReceivedQty, RejectedQty, ModifiedDate, ModifiedBy) values (250, 85, 36, 21, 20, GETDATE(), ORIGINAL_LOGIN());

INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 4, 96, 7, 1, 0, 2.00, '10-30-2017', 2.00, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 7, 199, 13, 1, 0, 2.82, '10-26-2017', 0.00, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 10, 46, 22, 1, 0, 1.00, '10-29-2017', 1.00, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 10, 49, 22, 1, 1, 17.28, '10-29-2017', 5.00, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 10, 182, 22, 1, 0, 1.00, '10-29-2017', 1.00, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 13, 142, 26, 1, 0, 2.50, '10-30-2017', 2.50, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 17, 180, 31, 1, 0, 0.50, '11-01-2017', 0.50, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 19, 92, 33, 1, 0, 1.50, '11-02-2017', 1.50, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 20, 6, 34, 1, 0, 2.00, '11-02-2017', 0.00, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 23, 83, 12, 0, 1, 4.30, '11-06-2017', 4.30, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 24, 157, 43, 1, 0, 18.96, '11-06-2017', 0.00, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 27, 23, 47, 1, 0, 9.99, '2017-11-02', 0.00, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 29, 2, 5, 1, 0, 5.50, '11-08-2017', 5.50, GETDATE(), ORIGINAL_LOGIN())
INSERT INTO Fees (TrackID, PubID, CustID, Overdue, Damage, CompAmount, CompDue, CompPaid, ModifiedDate, ModifiedBy) VALUES ( 29, 112, 5, 1, 1, 22.60, '11-08-2017', 14.50, GETDATE(), ORIGINAL_LOGIN())

