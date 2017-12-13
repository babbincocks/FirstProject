USE master
IF (SELECT COUNT(*) FROM sys.databases WHERE name = 'JobSearchPlus') > 0
BEGIN
DROP DATABASE JobSearchPlus
END

CREATE DATABASE JobSearchPlus

GO

USE JobSearchPlus;

CREATE TABLE BusinessTypes
(
	BusinessType VARCHAR(255) NOT NULL,
	PRIMARY KEY (BusinessType)
)
;

CREATE TABLE Companies
(	CompanyID INT IDENTITY(1,1),
	CompanyName VARCHAR(75) NOT NULL,
	Address1 VARCHAR(75) NULL,
	Address2 VARCHAR(75) NULL,
	City VARCHAR(50) NULL,
	[State] Varchar(2) NULL,
	ZIP VARCHAR(10) NULL,
	Phone VARCHAR(14) NULL,
	Fax VARCHAR(14) NULL,
	EMail VARCHAR(50) NULL,
	Website VARCHAR(50) NULL,
	[Description] VARCHAR(2048) NULL,
	BusinessType VARCHAR(255) NULL,
	Agency BIT DEFAULT 0
	CONSTRAINT PK_CompanyID PRIMARY KEY (CompanyID)
	
)
;
CREATE INDEX ind_CompanyName ON Companies(CompanyName);
CREATE INDEX ind_City ON Companies(City);
CREATE INDEX ind_State ON Companies([State]);
CREATE INDEX ind_ZIP ON Companies(ZIP);

CREATE TABLE Sources
(	SourceID INT IDENTITY(1,1),
	SourceName VARCHAR(75) NOT NULL,
	SourceType VARCHAR(35) NULL,
	SourceLink VARCHAR(255) NULL,
	[Description] VARCHAR(255) NULL
	CONSTRAINT PK_SourceID PRIMARY KEY (SourceID)
)
;
CREATE UNIQUE INDEX ind_SourceName ON Sources(SourceName);
CREATE INDEX ind_SourceType ON Sources(SourceType);

CREATE TABLE Contacts
(	ContactID INT IDENTITY(1,1),
	CompanyID INT NOT NULL,
	CourtesyTitle VARCHAR(25) NULL,
	ContactFirstName VARCHAR(50) NULL,
	ContactLastName VARCHAR(50) NULL,
	Title VARCHAR(50) NULL,
	Phone VARCHAR(14) NULL,
	Extension VARCHAR(10) NULL,
	Fax VARCHAR(14) NULL,
	EMail VARCHAR(50) NULL,
	Comments VARCHAR(255) NULL,
	Active BIT DEFAULT -1
	CONSTRAINT PK_ContactID PRIMARY KEY (ContactID)
)
;
CREATE INDEX ind_CompanyID ON Contacts(CompanyID);
CREATE INDEX ind_ContactLastName ON Contacts(ContactLastName);
CREATE INDEX ind_Title ON Contacts(Title);

CREATE TABLE Leads
(	LeadID INT IDENTITY(1,1),
	RecordDate DATE NOT NULL DEFAULT GETDATE(),
	JobTitle VARCHAR(75) NOT NULL,
	[Description] VARCHAR(2048) NULL,
	EmploymentType VARCHAR(25) NULL,
	Location VARCHAR(50) NULL,
	Active BIT DEFAULT -1,
	CompanyID INT NULL,
	AgencyID INT NULL,
	ContactID INT NULL,
	SourceID INT NULL,
	Selected BIT DEFAULT 0,
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
	CONSTRAINT PK_LeadID PRIMARY KEY (LeadID),
	CONSTRAINT CK_RecordDateFuture CHECK (RecordDate <= GETDATE()),
	CONSTRAINT CK_EmploymentType CHECK (EmploymentType IN ('Full-time','Full Time','Part-time','Part Time','Contractor','Temporary','Seasonal','Intern','Freelance','Volunteer')),
	

)
;
CREATE INDEX ind_SourceID ON Leads(SourceID);
CREATE INDEX ind_ContactID ON Leads(ContactID);
CREATE INDEX ind_AgencyID ON Leads(AgencyID);
CREATE INDEX ind_CompanyID ON Leads(CompanyID);
CREATE INDEX ind_Location ON Leads(Location);
CREATE INDEX ind_EmploymentType ON Leads(EmploymentType);
CREATE INDEX ind_RecordDate ON Leads(RecordDate);
;

CREATE TABLE Activities
(	ActivityID INT IDENTITY(1,1),
	LeadID INT NOT NULL,
	ActivityDate DATE NOT NULL DEFAULT GETDATE(),
	ActivityType VARCHAR(25) NOT NULL,
	ActivityDetails VARCHAR(255) NULL,
	Complete BIT NOT NULL DEFAULT 0,
	ReferenceLink VARCHAR(255) NULL,
	CONSTRAINT PK_Activities_ActivityID PRIMARY KEY (ActivityID),
	CONSTRAINT CK_ActiveTypeValid CHECK (ActivityType IN ('Inquiry', 'Application','Contact','Interview','Follow-up','Correspondence','Documentation','Closure','Other'))
);

CREATE INDEX ind_LeadID ON Activities(LeadID);
CREATE INDEX ind_ActivityDate ON Activities(ActivityDate);
CREATE INDEX ind_ActivityType ON Activities(ActivityType);

GO


CREATE TRIGGER trg_BusinessTypes_Companies
ON BusinessTypes
AFTER UPDATE
AS
BEGIN
	IF  EXISTS (SELECT *
				FROM deleted D, Companies C
				WHERE D.BusinessType = C.BusinessType)
			BEGIN
			DECLARE @In VARCHAR(255) = (SELECT I.BusinessType
								FROM inserted I
								)
				UPDATE Companies
				SET BusinessType = @In
				FROM deleted D, Companies C
				WHERE D.BusinessType = C.BusinessType
						
						


			END






END

GO



CREATE TRIGGER trg_BusinessTypes_DeleteTree
ON BusinessTypes
INSTEAD OF DELETE
AS
BEGIN

		IF EXISTS (	SELECT * 
					FROM Companies C, deleted D
					WHERE d.BusinessType = C.BusinessType)
					
						RAISERROR ('Delete or update all instances of this business type in the Companies table before deleting this business type.', 16, 1)
					


END

GO


CREATE TRIGGER trg_LeadUpdateDate
ON Leads
AFTER UPDATE
AS
BEGIN
		DECLARE @a INT
		SET @a = (SELECT LeadID FROM inserted)
		UPDATE Leads
		SET ModifiedDate = GETDATE()
		WHERE LeadID = @a




END
GO

CREATE TRIGGER trg_ActiveUpdateDate
ON Activities
AFTER INSERT, UPDATE
AS
BEGIN
		DECLARE @a INT
		SET @a = (SELECT LeadID FROM inserted)
		UPDATE Leads
		SET ModifiedDate = GETDATE()
		WHERE LeadID = @a




END

GO




CREATE TRIGGER trg_Leads_FK
ON Leads
AFTER  INSERT, UPDATE
AS
BEGIN

	IF    EXISTS (SELECT * FROM inserted WHERE AgencyID IS NOT NULL)
		BEGIN

		IF     EXISTS    (SELECT * 
							FROM Companies C, inserted I
							WHERE Agency = 0 AND C.CompanyID = i.AgencyID)
				 
					
						BEGIN	
								RAISERROR ('Only Agencies may appear in the AgencyID field. Check the Companies table and try again.', 16, 1)
								ROLLBACK TRANSACTION
						END	
					
			
		END
	
	IF EXISTS (SELECT * FROM inserted WHERE CompanyID IS NOT NULL)
		BEGIN

		IF EXISTS (SELECT *
					FROM inserted
					WHERE CompanyID NOT IN (SELECT CompanyID FROM Companies))

					BEGIN
						RAISERROR ('Only valid companies can be inserted into the Leads table. Check the Companies table and try again.', 16, 1)
						ROLLBACK TRANSACTION
					END


		END

		IF EXISTS (SELECT * FROM inserted WHERE ContactID IS NOT NULL)
			BEGIN

			IF EXISTS (SELECT *
					FROM inserted
					WHERE ContactID NOT IN (SELECT ContactID FROM Contacts))

					BEGIN
						RAISERROR ('Only valid contacts can be inserted into the Leads table. Check the Contacts table and try again.', 16, 1)
						ROLLBACK TRANSACTION
					END



			END

		IF EXISTS (SELECT * FROM inserted WHERE SourceID IS NOT NULL)
			BEGIN

			IF EXISTS (SELECT *
					FROM inserted
					WHERE SourceID NOT IN (SELECT SourceID FROM Sources))

					BEGIN
						RAISERROR ('Only valid sources can be inserted into the Leads table. Check the Sources table and try again.', 16, 1)
						ROLLBACK TRANSACTION
					END



			END
END
GO
PRINT 'INSERT Trigger Created'

GO

CREATE TRIGGER trg_Leads_DeleteTree
ON Leads
INSTEAD OF DELETE
AS
BEGIN

		IF EXISTS (	SELECT * 
					FROM Activities A, deleted D
					WHERE d.LeadID = A.LeadID)
					BEGIN
						RAISERROR ('Delete or update all instances of this lead in the Activities table before deleting this lead.', 16, 1)
					END

		
END
GO


--Companies connects to BusinessTypes
CREATE TRIGGER trg_Companies_CreateFK
ON Companies
AFTER INSERT, UPDATE
AS
BEGIN

-- If a value is inserted into Companies, it must be in BusinessTypes as well. It also must allow NULLS.
	IF  EXISTS (SELECT *
				FROM  inserted
				WHERE BusinessType IS NOT NULL
				GROUP BY BusinessType
				HAVING BusinessType NOT IN 
				(SELECT BusinessType FROM BusinessTypes)
				)
				
				BEGIN
								RAISERROR ('Invalid Business Type inserted. Refer to the BusinessTypes table and try again.', 16, 1)
								ROLLBACK TRANSACTION 
									
				END
--If a CompanyID is changed in Companies that also shows up in Contacts (for whatever reason), the entry in Contacts will be updated as well.
			IF  EXISTS (SELECT *
				FROM deleted D, Contacts C
				WHERE D.CompanyID = C.CompanyID)
			BEGIN
			DECLARE @In INT = (SELECT I.CompanyID
								FROM inserted I
								)
				UPDATE Contacts
				SET CompanyID = @In
				FROM deleted D, Contacts C
				WHERE D.CompanyID = C.CompanyID
						
						


			END
			
END

GO

CREATE TRIGGER trg_Companies_DeleteTree
ON Companies
INSTEAD OF DELETE
AS
BEGIN

		IF EXISTS (	SELECT * 
					FROM Contacts C, deleted D
					WHERE d.CompanyID = C.CompanyID)
					BEGIN
						RAISERROR ('Delete or update all instances of this company in the Contacts table before deleting this company.', 16, 1)
					END

		IF EXISTS (	SELECT * 
					FROM Leads L, deleted D
					WHERE d.CompanyID = L.CompanyID OR d.CompanyID = L.AgencyID)
					BEGIN
						RAISERROR ('Delete or update all instances of this company/agency in the Leads table before deleting this company.', 16, 1)
					END

END

GO

--SELECT * FROM Companies

--INSERT Companies (CompanyName, BusinessType)
--VALUES ('Brimbo Fungus Inc.', 'Account')
--SELECT * FROM Companies

--If BusinessTypes is updated, the instances of it in Companies needs to change as well.


--Contacts connects to Companies

CREATE TRIGGER trg_Sources_DeleteTree
ON Sources
INSTEAD OF DELETE
AS
BEGIN

		IF EXISTS (	SELECT * 
					FROM Leads L, deleted D
					WHERE d.SourceID = L.SourceID)
					BEGIN
						RAISERROR ('Delete or update all instances of this source in the Leads table before deleting this source.', 16, 1)
					END




END

GO

----------CREATE TRIGGER trg_Sources_FK
----------ON Sources
----------AFTER INSERT, UPDATE
----------AS 
----------BEGIN

		





----------END
----------GO

CREATE TRIGGER trg_Contacts_DeleteTree
ON Contacts
INSTEAD OF DELETE
AS
BEGIN

		IF EXISTS (	SELECT * 
					FROM Leads L, deleted D
					WHERE d.ContactID = L.ContactID)
					BEGIN
						RAISERROR ('Delete or update all instances of this contact in the Leads table before deleting this contact.', 16, 1)
					END




END

GO

--Leads connects to Companies (CompanyID and AgencyID), Contacts, and Sources


--Activities connect to Leads







;
INSERT INTO BusinessTypes (BusinessType)
VALUES 
('Accounting'),
('Advertising/Marketing'),
('Agriculture'),
('Architecture'),
('Arts/Entertainment'),
('Aviation'),
('Beauty/Fitness'),
('Business Services'),
('Communications'),
('Computer/Hardware'),
('Computer/Services'),
('Computer/Software'),
('Computer/Training'),
('Construction'),
('Consulting'),
('Crafts/Hobbies'),
('Education'),
('Electrical'),
('Electronics'),
('Employment'),
('Engineering'),
('Environmental'),
('Fashion'),
('Financial'),
('Food/Beverage'),
('Government'),
('Health/Medicine'),
('Home & Garden'),
('Immigration'),
('Import/Export'),
('Industrial'),
('Industrial Medicine'),
('Information Services'),
('Insurance'),
('Internet'),
('Legal & Law'),
('Logistics'),
('Manufacturing'),
('Mapping/Surveying'),
('Marine/Maritime'),
('Motor Vehicle'),
('Multimedia'),
('Network Marketing'),
('News & Weather'),
('Non-Profit'),
('Petrochemical'),
('Pharmaceutical'),
('Printing/Publishing'),
('Real Estate'),
('Restaurants'),
('Restaurants Services'),
('Service Clubs'),
('Service Industry'),
('Shopping/Retail'),
('Spiritual/Religious'),
('Sports/Recreation'),
('Storage/Warehousing'),
('Technologies'),
('Transportation'),
('Travel'),
('Utilities'),
('Venture Capital'),
('Wholesale')
;

INSERT Sources (SourceName, SourceType, SourceLink)
VALUES (
		'Monster.com',
		'Online',
		'https://www.monster.com/'
);
INSERT Sources (SourceName, SourceType, SourceLink)
VALUES (
		'EmployFlorida.com',
		'Online',
		'https://www.employflorida.com/'
);

INSERT Companies (CompanyName, Address1, Address2, City, [State], ZIP, Phone, Fax, EMail, Website, BusinessType, Agency)
VALUES ('Pactera Technologies', '14980 Northeast 31st Way', '#120', 'Redmond', 'WA', '98052', '(425) 233-8578', NULL, NULL, 'https://en.pactera.com/', 'Computer/Services', 0)
;
INSERT Companies (CompanyName, Address1, Address2, City, [State], ZIP, Phone, Fax, EMail, Website, BusinessType, Agency)
VALUES ('Lockheed Martin', NULL, NULL, 'Orlando', 'FL', NULL, NULL, NULL, NULL, 'https://search.lockheedmartinjobs.com/', 'Computer/Software', 0)
;
INSERT Companies (CompanyName, Address1, Address2, City, [State], ZIP, Phone, Fax, EMail, Website, BusinessType, Agency)
VALUES ('JDi Data Corporation', '100 W Cypress Creek Rd', 'Suite 1052', 'Fort Lauderdale', 'FL', '33309', '(954) 938-9100', NULL, NULL, 'https://www.jdidata.com/', 'Computer/Software', 0)
;
INSERT Companies (CompanyName, Address1, Address2, City, [State], ZIP, Phone, Fax, EMail, Website, BusinessType, Agency)
VALUES ('Alion Science and Technology', '12633 Challenger Pkwy', '#250', 'Orlando', 'FL', '32826', '(407) 737-3599', NULL, NULL, 'http://www.alionscience.com/','Technologies', 0)

INSERT Companies (CompanyName, Address1, Address2, City, [State], ZIP, Phone, Fax, EMail, Website, BusinessType, Agency)
VALUES ('AppleOne', '500 W Cypress Creek Rd', '#150', 'Fort Lauderdale', 'FL', '33309', '(954) 492-0550', NULL, NULL, 'https://www.appleone.com/', NULL, 1)

INSERT Contacts (CompanyID, CourtesyTitle, ContactFirstName, ContactLastName, Title, Phone, Extension, Fax, EMail, Comments, Active)
VALUES (1, 'Mr.', 'Harry', 'Simmons', 'Hiring Manager', '(425) 233-8578', '38879', NULL, NULL, NULL, 1)
;
INSERT Contacts (CompanyID, CourtesyTitle, ContactFirstName, ContactLastName, Title, Phone, Extension, Fax, EMail, Comments, Active)
VALUES (2, 'Ms.', 'Rowena', 'Burns', 'Hiring Manager', NULL, NULL, NULL, NULL, NULL, 1)
;
INSERT Contacts (CompanyID, CourtesyTitle, ContactFirstName, ContactLastName, Title, Phone, Extension, Fax, EMail, Comments, Active)
VALUES (3, 'Mrs.', 'Francine', 'Trudeau', 'HR Associate', '(954) 938-9100', '7382', NULL, NULL, NULL, 1)
;
INSERT Contacts (CompanyID, CourtesyTitle, ContactFirstName, ContactLastName, Title, Phone, Extension, Fax, EMail, Comments, Active)
VALUES (4, 'Mr.', 'Trey', 'Court', 'Hiring Manager', '(407) 737-3599', '3399', NULL, NULL, NULL, 1)
;
INSERT Contacts (CompanyID, CourtesyTitle, ContactFirstName, ContactLastName, Title, Phone, Extension, Fax, EMail, Comments, Active)
VALUES (5, 'Mr.', 'Franklin', 'McBride', 'Hiring Manager', '(954) 492-0550', '783', NULL, NULL, NULL, 1)
;

INSERT Leads (RecordDate, JobTitle, [Description], EmploymentType, Location, Active, CompanyID, AgencyID, ContactID, SourceID, Selected)
VALUES ('12-05-2017', 'Software Development Engineer', 
											'We are looking for traditional SDE who is strong coding with C# and preferably has written Autopilot watchdogs or at least has 
											experience with Autopilot. Candidates with past MS experience is a plus. The skills requirement are the following: Fluent in C#, 
											fundamentals of cloud engineering (understanding of distributed systems, building for scale, understanding of ways to handle disaster 
											recovery, high service availability etc), SQL, 3 to 5 years of experience in relevant field', 
		'Full-time', 'Redmond, WA 98052', 1, 1, NULL, 1, 1, NULL
)
;

PRINT 'Lead 1'
INSERT Leads (RecordDate, JobTitle, [Description], EmploymentType, Location, Active, CompanyID, AgencyID, ContactID, SourceID)
VALUES ('12-05-2017', 'Software Development Analyst Associate', 
															'Will have an opportunity to work with a diverse team ensuring the successful completion of software development activities aimed to support Lockheed Martin program supply chain logistics operational requirements. 
															Will design, develop, document and test software that contains logical and mathematical solutions taking into account project constraints of scope, cost, risk and schedule. Technical fortitude and dedicated focus shall be required for successful code implementations to a large scale logistics/supply chain management system that will interface with multiple external systems in its support of program supply chain logistics operational requirements. 
															This position will grow skills that will learn to articulate technical requirements to non-technical customers to ensure understanding of capabilities being developed and released to both internal and external users. 
															This position interacts with personnel on fairly complex technical matters often requiring coordination, collaboration and decisive actions to assure project success with minimum risk. Position develops technical solutions to complex problems, which require the regular use of ingenuity and creativity while keeping team leads and management informed with status reports, metrics and key milestones.',
		'Full-time', 'Orlando, FL', 1, 2, NULL, 2, 1
)
;
PRINT 'Lead 2'
INSERT Leads (RecordDate, JobTitle, [Description], EmploymentType, Location, Active, CompanyID, AgencyID, ContactID, SourceID)
VALUES ('12-05-2017', 'Junior Software Engineer', 
						'We are looking for software engineers. If you have a desire to stretch yourself to support the delivery of 
						great products and features then JDi Data is the perfect place for you! Responsibilities Include: 
						Review daily workload in issue tracking tool (Atlassian JIRA) with Sr. Software Engineer, 
						Read design documentation and review technical plan with Sr. Software Engineer, prior to making any changes, 
						Program changes according to approved technical plan, periodically checking in stable work to source control system 
						(Apache SVN), and Participate in peer code review (JetBrains UpSource). Theres a prize each month to the person that 
						performs best in peer code review! Perform unit testing of changes React to any issues uncovered in the continuous 
						integration (JetBrains TeamCity), automated testing processes (Selenium) and manual testing process, and Review 
						finished product with Sr. Software Engineer and adjust as needed.', 
		'Full-time', 'FORT LAUDERDALE, FL - 33308', 1, 3, NULL, 3, 2)
;
PRINT 'Lead 3'
INSERT Leads (RecordDate, JobTitle, [Description], EmploymentType, Location, Active, CompanyID, AgencyID, ContactID, SourceID)
VALUES ('12/05/17', 'Software Design Engineer Associate', NULL, 'Full-time', 'Orlando FL 32826', 1, 4, NULL, 4, 1)
;
PRINT 'Lead 4'
INSERT Leads (RecordDate, JobTitle, [Description], EmploymentType, Location, Active, CompanyID, AgencyID, ContactID, SourceID)
VALUES ('12/05/17', 'Software Developer', NULL, 'Full-time', 'Fort Lauderdale FL 33309', 1, 5, 5, 4, 1)
;
PRINT 'Lead 5'

INSERT Activities (LeadID, ActivityType, ActivityDetails, Complete)
VALUES (1, 'Inquiry', NULL, 1)
;
INSERT Activities (LeadID, ActivityType, ActivityDetails, Complete)
VALUES (2, 'Inquiry', NULL, 1)
;
INSERT Activities (LeadID, ActivityType, ActivityDetails, Complete)
VALUES (3, 'Inquiry', NULL, 1)
;
INSERT Activities (LeadID, ActivityType, ActivityDetails, Complete)
VALUES (4, 'Inquiry', NULL, 1)
;
INSERT Activities (LeadID, ActivityType, ActivityDetails, Complete)
VALUES (5, 'Inquiry', NULL, 1)
GO
;

--INSERT Leads (RecordDate, JobTitle, SourceID)
--VALUES ('01-01-2001', 'AAAAA', 6)
--SELECT * FROM Leads
