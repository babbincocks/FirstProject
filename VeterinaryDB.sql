USE master
IF (SELECT COUNT(*) FROM sys.databases WHERE name = 'VeterinaryDB') > 0
BEGIN
DROP DATABASE VeterinaryDB
END

CREATE DATABASE VeterinaryDB

IF (SELECT COUNT(*) FROM master.dbo.syslogins WHERE Name = 'VetManager') > 0
BEGIN

DROP LOGIN VetManager

END

IF (SELECT COUNT(*) FROM master.dbo.syslogins WHERE Name = 'VetClerk') > 0
BEGIN

DROP LOGIN VetClerk

END

CREATE LOGIN VetManager WITH PASSWORD = 'VManager'
CREATE LOGIN VetClerk WITH PASSWORD = 'VClerk'
ALTER LOGIN VetManager WITH DEFAULT_DATABASE = VeterinaryDB
ALTER LOGIN VetClerk WITH DEFAULT_DATABASE = VeterinaryDB
GO

USE VeterinaryDB

CREATE USER VetManager FOR LOGIN VetManager

ALTER ROLE db_datareader ADD MEMBER VetManager
ALTER ROLE db_datawriter ADD MEMBER VetManager

CREATE USER VetClerk FOR LOGIN VetClerk
ALTER ROLE db_datareader ADD MEMBER VetClerk
;
GO






GO
;
CREATE TABLE Clients
(
ClientID INT IDENTITY(1,1),
FirstName VARCHAR(25) NOT NULL,
LastName VARCHAR(25) NOT NULL,
MiddleName VARCHAR(25) NULL,
CreateDate DATE NOT NULL DEFAULT GETDATE()
CONSTRAINT PK_ClientID PRIMARY KEY (ClientID)
)
;

CREATE TABLE ClientContacts
(
AddressID INT IDENTITY(1,1),
ClientID INT NOT NULL,
AddressType INT NOT NULL,
AddressLine1 VARCHAR(50) NOT NULL,
AddressLine2 VARCHAR(50) NULL,
City VARCHAR(35) NOT NULL,
StateProvince VARCHAR(25) NOT NULL,
PostalCode VARCHAR(15) NOT NULL,
Phone VARCHAR(15) NOT NULL,
AltPhone VARCHAR(15) NULL,
Email VARCHAR(35) NULL
CONSTRAINT PK_AddressID PRIMARY KEY (AddressID),
CONSTRAINT FK_ClientContacts_Clients FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
CONSTRAINT CK_AddressTypes CHECK (AddressType IN (1, 2))
)
;

CREATE TABLE AnimalTypeReference
(
AnimalTypeID INT IDENTITY(1,1),
Species VARCHAR(35) NOT NULL,
Breed VARCHAR(35) NOT NULL
CONSTRAINT PK_AnimalTypeID PRIMARY KEY (AnimalTypeID)
)
;

CREATE TABLE Patients
(
PatientID INT IDENTITY(1,1),
ClientID INT NOT NULL,
PatName VARCHAR(35) NOT NULL,
AnimalType INT NOT NULL,
Color VARCHAR(25) NULL,
Gender VARCHAR(2) NOT NULL,
BirthYear VARCHAR(4) NULL,
[Weight] DECIMAL(7, 2) NOT NULL,
[Description] VARCHAR(1024) NULL,
GeneralNotes VARCHAR(2048) NOT NULL,
Chipped BIT NOT NULL,
RabiesVacc DATETIME NULL
CONSTRAINT PK_PatientID PRIMARY KEY(PatientID),
CONSTRAINT FK_Patients_Clients FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
CONSTRAINT FK_Patients_AnimalType FOREIGN KEY (AnimalType) REFERENCES AnimalTypeReference(AnimalTypeID)
)
;

CREATE TABLE Employees
(
EmployeeID INT IDENTITY(1,1),
LastName VARCHAR(25) NOT NULL,
FirstName VARCHAR(25) NOT NULL,
MiddleName VARCHAR(25) NOT NULL,
HireDate DATE NOT NULL,
Title VARCHAR(50) NOT NULL
CONSTRAINT PK_EmployeeID PRIMARY KEY (EmployeeID)
)
;

CREATE TABLE EmployeeContactInfo
(
AddressID INT IDENTITY(1,1),
EmployeeID INT NOT NULL,
AddressType INT NOT NULL,
AddressLine1 VARCHAR(50) NOT NULL,
AddressLine2 VARCHAR(50) NULL,
City VARCHAR(35) NOT NULL,
StateProvince VARCHAR(25) NOT NULL,
PostalCode VARCHAR(15) NOT NULL,
Phone VARCHAR(15) NOT NULL,
AltPhone VARCHAR(15) NULL,
Email VARCHAR(50) NULL
CONSTRAINT PK_EmployeeAddressID PRIMARY KEY (AddressID),
CONSTRAINT FK_EmployeeContact_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
)

CREATE TABLE Visits
(
VisitID INT IDENTITY(1,1),
StartTime DATETIME NOT NULL,
EndTime DATETIME NOT NULL,
Appointment BIT NOT NULL,
DiagnosisCode VARCHAR(12) NOT NULL,
ProcedureCode VARCHAR(12) NOT NULL,
VisitNotes VARCHAR(2048) NOT NULL,
PatientID INT NOT NULL,
EmployeeID INT NOT NULL
CONSTRAINT PK_VisitID PRIMARY KEY (VisitID),
CONSTRAINT FK_Visits_Patients FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
CONSTRAINT FK_Visits_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
CONSTRAINT CK_EndAfterStart CHECK (EndTime > StartTime)
)

CREATE TABLE Billing
(
BillID INT IDENTITY(1,1),
BillDate DATE NOT NULL,
ClientID INT NOT NULL,
VisitID INT NOT NULL,
Amount DECIMAL(15,2) NOT NULL
CONSTRAINT PK_BillID PRIMARY KEY (BillID),
CONSTRAINT FK_Billing_Clients FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
CONSTRAINT FK_Billing_Visits FOREIGN KEY (VisitID) REFERENCES Visits(VisitID),
CONSTRAINT CK_NoFutureBills CHECK (BillDate <= GETDATE())
)

CREATE TABLE Payments
(
PaymentID INT IDENTITY(1,1),
PaymentDate DATE NOT NULL,
BillID INT NULL,
Notes VARCHAR(2048) NULL,
Amount DECIMAL NOT NULL
CONSTRAINT PK_PaymentID PRIMARY KEY (PaymentID),
CONSTRAINT FK_Payments_Billing FOREIGN KEY (BillID) REFERENCES Billing(BillID),
CONSTRAINT CK_NoFuturePayments CHECK (PaymentDate <= GETDATE())
)

GO

--GRANT SELECT ON AnimalTypeReference TO VetClerk
--GRANT SELECT ON Billing TO VetClerk
--GRANT SELECT ON Clients TO VetClerk
--GRANT SELECT ON Employees TO VetClerk
--GRANT SELECT ON Patients TO VetClerk
--GRANT SELECT ON Payments TO VetClerk
--GRANT SELECT ON Visits TO VetClerk

DENY ALL ON OBJECT :: VeterinaryDB.dbo.ClientContacts TO VetClerk 
DENY ALL ON OBJECT :: VeterinaryDB.dbo.EmployeeContactInfo TO VetClerk

GO

INSERT Clients(FirstName, LastName, MiddleName)
VALUES ('Franklin','King', NULL), ('Jamie','Michaels', NULL), ('Derek','Tristram','Deckard'),
('Susan','Falcone','Nicole'), ('Ulrich','Sapkowski','Andrzej')

INSERT ClientContacts (ClientID, AddressType, AddressLine1, AddressLine2, City, StateProvince, 
						PostalCode, Phone, AltPhone, Email)
VALUES (1, 2, '422 Perigrin Lane', 'PO Box 578', 'Atlanta', 'Georgia', '30302', '404-555-1456', NULL, 'kingtres333@shmoogle.com')
,(2, 1, '8998 NE 46th Street', NULL, 'Ocala', 'Florida', '34471', '352-367-0005', '207-561-5544', NULL)
,(3, 1, '2789 SW 12th Avenue', NULL, 'Ocala', 'Florida', '34474', '352-999-2100', '998-555-1420', 'somethingdark01@shmoogle.com')
,(4, 1, '602 NE 98th Terrace', NULL, 'Gainesville', 'Florida', '32604', '352-782-1341', NULL, 'susanfalcone14@coldpost.net')
,(5, 2, '26 Gamle Torv', NULL, 'Slagelse', 'Norway', '4200', '58-11-5566', NULL, 'bestiltilen@postkasse.de')


INSERT AnimalTypeReference (Species, Breed)
VALUES ('Dog', 'German Shepherd'), ('Horse', 'American Quarter'), ('Cat', 'Russian Blue'), 
		('Cat', 'Himalayan'), ('Cat', 'Sphynx'), ('Dog', 'Pug')

INSERT Patients (ClientID, PatName, AnimalType, Color, Gender, BirthYear, [Weight], 
				[Description], GeneralNotes, Chipped, RabiesVacc)
VALUES (1, 'Snuffles', 1, 'Black', 'M', '2005', '12.6', NULL, 'Quite shaggy. Rough temperament. Slow to trust.', 0, '2-17-2016'),
		(2, 'Mystery', 2, 'White', 'M', '1999', '1080.55', NULL, 'Very calm temperament. Excellent strength.', 0, '8-22-2016'),
		(2, 'Shebana', 2, 'Chestnut', 'F', '1997', '1074.8', NULL, 'Quite rambunctious. Overall friendly attitude, but likes to move around a lot, which makes for a slightly harder time treating.', 0, '8-22-2016'),
		(3, 'Andy', 3, 'Grey', 'M', '1999', '11.52', NULL, 'Very old and fragile. Very friendly, all things considered.', 1, '4-28-2016'),
		(4, 'Crookshanks', 4, 'Ginger', 'F', '2004', '11.5', NULL, 'Very thick coated. Do not touch tail. ', 0, '10-13-2017'),
		(4, 'Kneazie', 5, NULL, 'F', '2007', '5.5', NULL, 'Yearly checkup. A bit underweight. Should be fed more.', 0, '10-13-2017'),
		(5, 'Lodne Dreng', 6, NULL, 'M', '2010', '12', NULL, 'Small pug. Was very excitable once revived.', 1, '1-22-2017')

INSERT Employees (LastName, FirstName, MiddleName, HireDate, Title)
VALUES ('Richards', 'Riquita', 'Maya', '4-14-2014', 'Desk Receptionist'),
		('Dawkins', 'Kashawndra', 'Aloray', '4-14-2014', 'Veterinarian'),
		('Park', 'Michael', 'Trey', '4-14-2014', 'Veterinarian Assistant'),
		('Pasquello', 'Cory', 'Francis', '4-14-2014', 'Office Manager'),
		('Hill', 'Nicole', 'Henrietta', '4-14-2014', 'Kennel Assistant'),
		('Moore', 'Brendan', 'William', '1-25-2015', 'Veterinarian'),
		('Grant', 'Francine', 'Purna', '2-9-2015', 'Janitor')

INSERT EmployeeContactInfo (EmployeeID, AddressType, AddressLine1, AddressLine2, City, StateProvince, PostalCode, Phone, AltPhone, Email)
VALUES (1, 1, '1489 NE 45th Lane', 'Apt. #268', 'Ocala', 'Florida', '34472', '352-999-4554', NULL, 'riqui_riqui@coldpost.com'),
(2, 1, '3801 SE 59th Place', NULL, 'Ocala', 'Florida', '34473', '352-331-1270', NULL, 'motheraether@shmoogle.com'),
(3, 1, '386 Meadow Vale Lane', NULL, 'Dunnellon', 'Florida', '34432', '352-568-9991', NULL, 'parkway67@coldpost.com'),
(4, 1, '9325 SE 11th Way', NULL, 'Ocala', 'Florida', '34470', '352-099-5665', NULL, 'cpasquello01@shmoogle.com'),
(5, 1, '4846 SW 68th Pass', 'Apt. #144', 'Ocala', 'Florida', '34474', '352-890-0000', '207-342-4255', 'nikkinacks11@coldpost.com'),
(6, 1, '3801 Crest Line Street', NULL, 'Belleview', 'Florida', '34421', '352-771-3095', NULL, 'williamb999@yoohoo.org'),
(7, 1, '8768 NW 24th Court', NULL, 'Ocala', 'Florida', '34475', '352-983-6662', NULL, 'grantf1991@coldpost.com')


INSERT Visits (StartTime, EndTime, Appointment, DiagnosisCode, ProcedureCode, VisitNotes, PatientID, EmployeeID)
VALUES ('05-22-2016 14:30:00.000', '05-22-2016 15:14:00.000', 1, '1920346697', '1P6924', 'Came in with irritated bowels. Found blockage consisting of hair and cereal. Medication was given to help pass blockage.', 1, 2), 
('08-22-2016 12:30:00.000', '08-22-2016 13:23:00.000', 1, '1119871499', '0T2134', 'Yearly checkup. Both American Quarter horses, impeccably cared for. No health issues found.', 2, 2), 
('02-10-2017 8:30:00.000', '02-10-2017 9:20:00.000', 1, '839014122G', '4C3209', 'Legs had stopped functioning due to age. Had to be put down.', 3, 6),
('04-27-2017 14:00:00.000', '04-27-2017 15:12:00.000', 1, '3829104123', '8F8934', 'Yearly checkup for two cats: Himalayan female and Sphynx female. Himalayan was almost in perfect health; coat is a bit too thick for it and should be trimmed. Sphynx was a bit underweight, but other than that was healthy. New diet was set up.', 4, 2), 
('07-25-2017 6:16:00.000', '07-25-2017 9:23:00.000', 0, '806952124G', '6B3298', 'Came in unresponsive. Was able to resuscitate, and made a full recovery. Cause seems to have been carrot lodged in throat.', 5, 6)

INSERT Billing (BillDate, ClientID, VisitID, Amount)
VALUES ('05-22-2016', 1, 1, 215.00), ('08-22-2016', 2, 2, 540.25), 
('02-13-2017', 3, 3, 115.00), ('04-27-2017', 4, 4, 365.17), ('07-28-2017', 5, 5, 415.50)


GO
CREATE PROC sp_SpeciesSearch
(
@Species VARCHAR(20)

)
AS
BEGIN
SELECT		ATR.Species [Patient Species], P.PatName [Patient Name], C.FirstName [Client First Name], 
			C.MiddleName [Client Middle Name], C.LastName [Client Last Name], CC.AddressLine1, 
			CC.AddressLine2, CC.City, CC.StateProvince, CC.PostalCode, CC.Phone, CC.AltPhone, CC.Email
FROM		AnimalTypeReference ATR
INNER JOIN	Patients P
ON			P.AnimalType = ATR.AnimalTypeID
INNER JOIN	Clients C
ON			C.ClientID = P.ClientID
INNER JOIN	ClientContacts CC
ON			CC.ClientID = C.ClientID
WHERE		ATR.Species = @Species

END


GO

CREATE PROC sp_BreedSearch
(
@Breed VARCHAR(20)

)
AS
BEGIN
SELECT		ATR.Breed [Patient Species], P.PatName [Patient Name], C.FirstName [Client First Name], 
			C.MiddleName [Client Middle Name], C.LastName [Client Last Name], CC.AddressLine1, 
			CC.AddressLine2, CC.City, CC.StateProvince, CC.PostalCode, CC.Phone, CC.AltPhone, CC.Email
FROM		AnimalTypeReference ATR
INNER JOIN	Patients P
ON			P.AnimalType = ATR.AnimalTypeID
INNER JOIN	Clients C
ON			C.ClientID = P.ClientID
INNER JOIN	ClientContacts CC
ON			CC.ClientID = C.ClientID
WHERE		ATR.Breed = @Breed

END


GO

CREATE PROC sp_ClientPayInfo
(
@Client INT
)
AS
BEGIN
SELECT B.ClientID, BillDate [Date Billed], PaymentDate [Date of Payment], CAST(V.EndTime AS DATE) [Date of Visit], B.Amount [Amount Billed], P.Amount [Amount Paid]
FROM Billing B
LEFT JOIN Payments P
ON P.BillID = B.BillID
INNER JOIN Visits V
ON V.VisitID = B.VisitID
WHERE @Client = ClientID

END

GO

CREATE PROC sp_EmployMailList

AS
BEGIN
	SELECT E.FirstName, E.MiddleName, E.LastName, AddressLine1, AddressLine2, City, StateProvince, PostalCode, Phone
	FROM Employees E
	INNER JOIN EmployeeContactInfo I
	ON I.EmployeeID = E.EmployeeID

END

GO

GRANT EXECUTE ON sp_EmployMailList TO VetClerk
GRANT EXECUTE ON sp_ClientPayInfo TO VetClerk
GRANT EXECUTE ON sp_BreedSearch TO VetClerk
GRANT EXECUTE ON sp_SpeciesSearch TO VetClerk

GO

CREATE PROC sp_ClientInsert
(
@FirstName VARCHAR(25),
@LastName VARCHAR(25),
@AddressType INT,
@AddLine1 VARCHAR(50),
@City VARCHAR(35),
@StateProvince VARCHAR(25),
@ZIPCode VARCHAR(15),
@Phone VARCHAR(15),
@NewID INT OUTPUT
)
AS
BEGIN
	INSERT Clients (FirstName, LastName)
	VALUES (@FirstName, @LastName)
	SET @NewID = (SELECT TOP 1 SCOPE_IDENTITY() FROM Clients) 
	INSERT ClientContacts (ClientID, AddressType, AddressLine1, City, StateProvince, PostalCode, Phone)
	VALUES (@NewID, @AddressType, @AddLine1, @City, @StateProvince, @ZIPCode, @Phone)

	SELECT @NewID [New Client ID]

END
GO

CREATE PROC sp_EmployeeInsert
(
@FirstName VARCHAR(25),
@LastName VARCHAR(25),
@MiddleName VARCHAR(25),
@HireDate DATE,
@JobTitle VARCHAR(50),
@AddressType INT,
@AddLine1 VARCHAR(50),
@City VARCHAR(35),
@StateProvince VARCHAR(25),
@ZIPCode VARCHAR(15),
@Phone VARCHAR(15),
@NewID INT OUTPUT
)
AS
BEGIN
	
	INSERT Employees(LastName, FirstName, MiddleName, HireDate, Title)
	VALUES (@LastName, @FirstName, @MiddleName, @HireDate, @JobTitle)
	SET @NewID = (SELECT TOP 1 SCOPE_IDENTITY() FROM Employees) 
	INSERT EmployeeContactInfo(EmployeeID, AddressType, AddressLine1, City, StateProvince, PostalCode, Phone)
	VALUES (@NewID, @AddressType, @AddLine1, @City, @StateProvince, @ZIPCode, @Phone)

	SELECT @NewID [New Employee ID]


END
GO
