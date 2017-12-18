CREATE PROC sp_PrimeGen
(	@Counter INT = 1,
	 @Limit INT = 1,
	 @Prime INT = 1
)
AS
BEGIN
	
	WHILE @Counter <= @Limit
		
			
		BEGIN

			PRINT @Prime

		
			SET @Counter = @Counter + 1
		END


END




EXEC sp_PrimeGen @Counter = 1 , @Limit = 4 

DROP PROC sp_PrimeGen

GO



