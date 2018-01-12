USE AdventureWorks2012



DECLARE RandStatus CURSOR FOR

SELECT TOP 1000 [Status] 
FROM sales.SalesOrderHeader
ORDER BY SalesOrderID;



OPEN RandStatus

FETCH NEXT FROM RandStatus

DECLARE @State INT

WHILE @@FETCH_STATUS = 0

BEGIN
	
	SET @State = (SELECT CEILING(RAND() * 3) )


		UPDATE Sales.SalesOrderHeader
		SET [Status] = @State
		WHERE CURRENT OF RandStatus

	FETCH NEXT FROM RandStatus

END

CLOSE RandStatus
DEALLOCATE RandStatus


GO


CREATE PROC sp_UpdateStatusRest
AS
BEGIN

	DECLARE @Counter INT = 1
	DECLARE @Max INT = ((SELECT TOP 1 row_count
						FROM sys.dm_db_partition_stats
						WHERE [object_id] = OBJECT_ID('AdventureWorks2012.Sales.SalesOrderHeader')) - 1000)
	WHILE @Counter <= @Max
		BEGIN
			UPDATE Sales.SalesOrderHeader
			SET [Status] = (SELECT CEILING(RAND() * 3))
			WHERE SalesOrderID = 
			(SELECT TOP 1 SalesOrderID FROM Sales.SalesOrderHeader WHERE [Status] = 5)

			SET @Counter = @Counter + 1
		END
	
END
--Or just use this

--UPDATE Sales.SalesOrderHeader
--SET [Status] = ABS(CHECKSUM(NEWID() )% 3) + 1
--WHERE [Status] = 5
GO


EXEC sp_UpdateStatusRest



GO

CREATE FUNCTION fn_ProductIDQuant
(
@ProductID INT
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @Quant SMALLINT = (SELECT SUM(Quantity)
								FROM Production.ProductInventory I 
								INNER JOIN Production.Product P 
								ON P.ProductID = I.ProductID 
								WHERE P.ProductID = @ProductID)

		IF @Quant IS NULL
			BEGIN
				SET @Quant = 0
			END


	RETURN @Quant
END
GO

--SELECT dbo.fn_ProductIDQuant(2)


GO

CREATE FUNCTION fn_ProductNumQuant
(
@ProductNumber NVARCHAR(25)
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @Quant SMALLINT = (SELECT SUM(Quantity)
								FROM Production.ProductInventory I 
								INNER JOIN Production.Product P 
								ON P.ProductID = I.ProductID 
								WHERE P.ProductNumber = @ProductNumber)

		IF @Quant IS NULL
			BEGIN
				SET @Quant = 0
			END


	RETURN @Quant
END
GO

--SELECT dbo.fn_ProductNumQuant('BA-8327')


GO

CREATE PROC sp_Shipoff
AS
BEGIN
		
		WITH ToShip AS
		(SELECT H.*
		FROM Sales.SalesOrderHeader H 
	INNER JOIN Sales.SalesOrderDetail D 
	ON D.SalesOrderID = H.SalesOrderID 
	INNER JOIN Production.ProductInventory I 
	ON I.ProductID = D.ProductID
	WHERE [Status] IN (1, 2, 3) AND NOT (H.BillToAddressID IS NULL OR 
				H.ShipToAddressID IS NULL OR 
				H.CreditCardID IS NULL OR 
				H.CreditCardApprovalCode IS NULL))
				--6314
		UPDATE Sales.SalesOrderHeader
		SET [Status] = 5
	WHERE SalesOrderID IN (SELECT SalesOrderID FROM ToShip)

END
GO

EXEC sp_Shipoff