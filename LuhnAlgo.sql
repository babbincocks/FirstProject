USE AdventureWorks2012

GO

CREATE FUNCTION [dbo].[fn_ValidCardCheck]
(@Card BIGINT)
RETURNS BIT
AS
BEGIN

--This first variable is for reversing the card number (so I don't need to type REVERSE so much).
DECLARE @Number VARCHAR(20) = REVERSE(@Card)
--BIT field for whether the card number is valid.
DECLARE @Valid BIT = 0
--What position of the card number is being modified.
DECLARE @Pos TINYINT = 2
--Sum of all digits in card number when it's modified.
DECLARE @Sum BIGINT = 0
--Essentially a little slider that will move along the modified card number for calculating the sum.
DECLARE @Slide INT = 1

WHILE @Pos <= LEN(@Number)
	BEGIN
		IF (SUBSTRING(@Number, @Pos, 1) * 2) >= 10
			BEGIN
				SET @Number = STUFF(@Number, @Pos, 1, (SUBSTRING(@Number, @Pos, 1) * 2) - 9)
			END
		ELSE
			BEGIN
				SET @Number = STUFF(@Number, @Pos, 1, (SUBSTRING(@Number, @Pos, 1) * 2))
			END

		SET @Pos = @Pos + 2
	END
	WHILE @Slide <= LEN(@Number)
	BEGIN
	SET @Sum = @Sum + CAST(SUBSTRING(@Number, @Slide, 1) AS int)
	SET @Slide = @Slide + 1
	END

IF (@Sum % 10) = 0
	SET @Valid = 1


RETURN @Valid
END

GO

--SELECT dbo.fn_ValidCardCheck(77775313211885)

ALTER TABLE Sales.CreditCard

ADD ValidCard BIT

--SELECT * FROM Sales.CreditCard WHERE ValidCard = 1
GO

CREATE PROC sp_ValidCreditCardCheck
AS
BEGIN

	UPDATE Sales.CreditCard
	SET ValidCard = dbo.fn_ValidCardCheck(CardNumber)
	FROM Sales.CreditCard
	WHERE ValidCard IS NULL

END

GO

--EXEC sp_ValidCreditCardCheck

--SELECT * FROM Sales.CreditCard

--Finished at 7:19 PM 03-22-2018

