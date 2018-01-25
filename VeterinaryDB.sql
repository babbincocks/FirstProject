USE master
IF (SELECT COUNT(*) FROM sys.databases WHERE name = 'VeterinaryDB') > 0
BEGIN
DROP DATABASE VeterinaryDB
END

CREATE DATABASE VeterinaryDB

GO

USE VeterinaryDB

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
AltPhone VARCHAR(15) NOT NULL,
Email VARCHAR(35) NOT NULL
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
CONSTRAINT PK_AddressID PRIMARY KEY (AddressID),
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
Amount DECIMAL NOT NULL
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

INSERT Clients(FirstName, LastName, MiddleName)
VALUES ('Franklin','King', NULL), ('Jamie','Michaels', NULL), ('Derek','Tristram','Deckard'),
('Susan','Falcone','Nicole'), ('Ulrich','Sapkowski','Andrzej')

INSERT ClientContacts (ClientID, AddressType, AddressLine1, AddressLine2, City, StateProvince, 
						PostalCode, Phone, AltPhone, Email)
VALUES (1, 2, '422 Perigrin Lane', 'PO Box 578', 'Atlanta', 'Georgia', '30302', '404-555-1456', '404-888-7423', 'kingtres333@shmoogle.com')
,(2, 1, '8998 NE 46th Street', NULL, 'Ocala', 'Florida', '34471', '352-367-0005', '207-561-5544', 'horsesofhorsia14@shmoogle.com')
,(3, 1, '2789 SW 12th Avenue', NULL, 'Ocala', 'Florida', '34474', '352-999-2100', '998-555-1420', 'somethingdark01@shmoogle.com')
,(4, 1, '602 NE 98th Terrace', NULL, 'Gainesville', 'Florida', '32604', '352-782-1341', '898-555-4782', 'susanfalcone14@coldpost.net')
,(5, 2, '26 Gamle Torv', NULL, 'Slagelse', 'Norway', '4200', '58-11-5566', '58-11-0000', 'bestiltilen@postkasse.de')


INSERT AnimalTypeReference (Species, Breed)
VALUES ('Dog', 'German Shepherd'), ('Horse', 'American Quarter'), ('Cat', 'Russian Blue'), ('Cat', 'Himalayan'), ('Cat', 'Sphynx'), ('Dog', 'Pug')

INSERT Patients (ClientID, PatName, AnimalType, Color, Gender, BirthYear, [Weight], 
				[Description], GeneralNotes, Chipped, RabiesVacc)
VALUES (1, 'Snuffles', 1, 'Black', 'F', '2005', '12.6', NULL, 'Came in with irritated bowels. Found blockage consisting of hair and cereal. Medication was given to help pass blockage.', 0, '2-17-2016'),
		(2, 'Mystery', 2, 'White', 'M', '1999', '1080.55', NULL, 'Yearly checkup. Impeccably cared for. No health issues found.', 0, '8-22-2016'),
		(2, 'Shebana', 2, 'Chestnut', 'F', '1997', '1074.8', NULL, 'Yearly checkup. Impeccably cared for. No health issues found.', 0, '8-22-2016'),
		(3, 'Andy', 3, 'Grey', 'M', '1999', '11.52', NULL, 'Legs had stopped functioning due to age. Had to be put down.', 1, '4-28-2016'),
		(4, 'Crookshanks', 4, 'Ginger', 'F', '2004', '11.5', NULL, 'Came in with irritated bowels. Found blockage consisting of hair and cereal. Medication was given to help pass blockage.', 0, '2-17-2016'),
		(4, 'Kneazie', 5, NULL, 'F', '2007', '5.5', NULL, 'Yearly checkup. A bit underweight. Should be fed more.', 0, '2-17-2016'),
		(5, 'Lodne Dreng', 6, NULL, 'M', '2010', '12', NULL, 'Came in unresponsive. Was able to resuscitate, and made a full recovery. Cause seems to have been carrot lodged in throat.', 1, '1-22-2017')