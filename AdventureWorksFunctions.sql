USE AdventureWorks2012

GO

CREATE FUNCTION [dbo].[fnCCExpire]
(
@CCNumber AS NVARCHAR(25)
)
RETURNS DATE
AS
BEGIN
	DECLARE  @ExpDate DATE 

	SET @ExpDate = (SELECT CONCAT( ExpYear, '-', ExpMonth, '-01') [Date] FROM Sales.CreditCard WHERE CardNumber = @CCNumber)
	
	SET @ExpDate = EOMONTH(@ExpDate)
	
	RETURN @ExpDate
END
GO

SELECT dbo.fnCCExpire (33332664695310)
SELECT dbo.fnCCExpire (55552127249722)
SELECT dbo.fnCCExpire (77774915718248)
SELECT dbo.fnCCExpire (11119905436490)
SELECT dbo.fnCCExpire (33333594431481)

CREATE FUNCTION [dbo].[fnProvinceTax]
(
@Province INT
)


SELECT * FROM Sales.SalesTaxRate
