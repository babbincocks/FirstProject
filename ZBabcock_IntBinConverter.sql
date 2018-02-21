USE Sandbox
GO

--DROP PROC sp_integerbinaryconvert

CREATE PROC sp_integerbinaryconvert
(
@String VARCHAR(100),
@InputNumberType VARCHAR(10),
@Output VARCHAR(100) = '' OUTPUT 
)
AS
BEGIN
IF @InputNumberType NOT IN ('Integer', 'Binary')
	BEGIN
	RAISERROR ('Valid values to put for the input number type are "Integer" or "Binary"; what you put in was neither.', 16, 1)
	RETURN
	END

IF @InputNumberType = 'Integer'
	BEGIN
	DECLARE @End INT = @String
	SET @Output = @End % 2
	WHILE @End > 1
		BEGIN
		SET @End = FLOOR(@End / 2)
		SET @Output = @Output + CAST((@End % 2) AS VARCHAR(1))
		END
	SET @Output = REVERSE(@Output)
	WHILE LEN(@Output) % 8 <> 0
		BEGIN
		SET @Output = '0' + @Output
		END
	END

IF @InputNumberType = 'Binary'
	BEGIN
	SET @String = REVERSE(@String)
	DECLARE @Multiple INT = 1
	DECLARE @Place INT = 1
	WHILE @Place <= LEN(@String)
		BEGIN
		IF SUBSTRING(@String, @Place, 1) = 1
			BEGIN
			SET @Output = @Output + @Multiple
			END
		SET @Multiple = @Multiple * 2
		SET @Place = @Place + 1
		END
	END

	SELECT @String [Input], @Output [Output]
	RETURN
END
GO

EXEC sp_integerbinaryconvert '65535', 'Integer'


CREATE TABLE BinaryAndInteger
(
[Input] VARCHAR(100),
[Output] VARCHAR(100)
)
GO

CREATE PROC sp_IntBinToTable
(
@NumberofRows INT
)
AS
BEGIN
IF (SELECT COUNT(*) FROM BinaryAndInteger) > 0
	BEGIN
	DELETE
	FROM BinaryAndInteger
	END
DECLARE @Counter INT = 1
WHILE (SELECT COUNT(*) FROM BinaryAndInteger) < @NumberofRows
	BEGIN
	
	
	INSERT BinaryAndInteger
	EXEC sp_integerbinaryconvert @Counter, 'Integer'

	SET @Counter = @Counter + 1

	END
	SELECT * FROM BinaryAndInteger
	RETURN
END

EXEC sp_IntBinToTable 10000



GO


