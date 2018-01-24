USE AdventureWorks2012
GO

--A function that uses the LIKE operator to pull Product names that contain a specific combination of characters

CREATE FUNCTION dbo.fnProductNameSearch
(
@String VARCHAR(40)
)
RETURNS TABLE
AS
RETURN
	SELECT *
	FROM Production.Product
	WHERE Name LIKE ('%' + @String + '%')

GO

-- A function that accepts an integer for a parameter and returns that number of the most recent orders in 
-- descending order by order date.

CREATE FUNCTION dbo.fnRecentOrders
(
@NumberofRows INT
)
RETURNS TABLE
AS
RETURN
	SELECT TOP (@NumberofRows) *
	FROM Sales.SalesOrderHeader
	ORDER BY OrderDate DESC



GO

--A function that accepts a string of numbers (i.e. '638') and then finds all the people with phone numbers 
--containing that number combination.

CREATE FUNCTION dbo.fnPhoneSearch
(
@NumberString VARCHAR(15)
)
RETURNS TABLE
AS
RETURN
	SELECT P.*, H.PhoneNumber, H.PhoneNumberTypeID, H.ModifiedDate [PhoneModifiedDate]
	FROM Person.PersonPhone H
	LEFT JOIN Person.Person P
	ON P.BusinessEntityID = H.BusinessEntityID
	WHERE H.PhoneNumber LIKE '%' + @NumberString + '%'

GO

-- A function that accepts a starting number (@StartNumber) and then returns the specified number of prime numbers 
-- (@PrimeCount) that come after it.

CREATE FUNCTION dbo.fnPrimeCheck
(
@Number INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @Divider INT = 2
	DECLARE @Prime BIT = 1
			
			WHILE @Divider <= (sqrt(@Number))
				BEGIN
					IF  (@Number % @Divider = 0)
						BEGIN 
							SET @Prime = 0
							BREAK
						END
						ELSE	 SET @Divider = @Divider + 1 
								
								
						
				END
		

RETURN @Prime
END

GO


	 
CREATE FUNCTION dbo.fnSequentialPrimes
(
@StartNumber INT,
@PrimeCount INT
)
RETURNS @Primes TABLE
(
[Prime Number] INT NOT NULL
)
AS	
BEGIN
	DECLARE @Counter INT = 1
	WHILE @Counter <= @PrimeCount
	BEGIN
		IF (SELECT dbo.fnPrimeCheck(@StartNumber)) = 1
		BEGIN
			INSERT @Primes 
			VALUES (@StartNumber)
			SET @Counter = @Counter + 1
			SET @StartNumber = @StartNumber + 1
		END
		IF (SELECT dbo.fnPrimeCheck(@StartNumber)) = 0
		BEGIN
			SET @StartNumber = @StartNumber + 1
		END
	END

	RETURN
END
GO

--SELECT *
--FROM dbo.fnSequentialPrimes(256, 30)