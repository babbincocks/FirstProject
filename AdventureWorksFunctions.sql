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

GO




CREATE FUNCTION [dbo].[fnProvinceTax]
(
@Province INT,
@Tax TINYINT
)
RETURNS SMALLMONEY
AS
BEGIN
	DECLARE @Rate SMALLMONEY

	SET @Rate = (SELECT TaxRate FROM Sales.SalesTaxRate WHERE StateProvinceID = @Province AND TaxType = @Tax)

	IF @Rate IS NULL
		BEGIN
		SET @Rate = 0
		END

	RETURN @Rate
END

GO

SELECT [dbo].[fnProvinceTax](1, 1)
SELECT [dbo].[fnProvinceTax](63, 2)
SELECT [dbo].[fnProvinceTax](57, 4)
SELECT [dbo].[fnProvinceTax](14, 2)
SELECT [dbo].[fnProvinceTax](35, 1)

GO


CREATE FUNCTION [dbo].[fnInchToCentimeter]
(
@Inches DECIMAL(18,4)
)
RETURNS DECIMAL(18,4)
AS
BEGIN
	DECLARE @Centimeter DECIMAL(18, 4) = (@Inches * 2.54)
	

	RETURN @Centimeter

END
GO


SELECT [dbo].[fnInchToCentimeter](1) 
SELECT [dbo].[fnInchToCentimeter](19) 
SELECT [dbo].[fnInchToCentimeter](4) 
SELECT [dbo].[fnInchToCentimeter](200) 
SELECT [dbo].[fnInchToCentimeter](42.56) 

GO

CREATE FUNCTION [dbo].[fnGallontoLiter]
(
@Gallon DECIMAL(20,10)
)
RETURNS DECIMAL(20,5)
AS
BEGIN
	DECLARE @Liter DECIMAL(20, 10) = (@Gallon * 3.78541)
	
	RETURN @Liter

END
GO


SELECT dbo.fnGallontoLiter(2)
SELECT dbo.fnGallontoLiter(10)
SELECT dbo.fnGallontoLiter(47)
SELECT dbo.fnGallontoLiter(13.77777)
SELECT dbo.fnGallontoLiter(51.580432)
