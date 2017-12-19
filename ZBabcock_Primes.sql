CREATE PROC sp_PrimeGen
(	
	 @Limit INT = ''
	
)
AS
BEGIN
	DECLARE @Counter INT = 2
	DECLARE @Prime BIT = 1
	WHILE @Limit > @Counter 
	BEGIN	
		IF  @Limit % @Counter = 0
		BEGIN
			SET @Prime = 0
			BREAK
		END
		
		SET @Counter = @Counter + 1
	END
			
			
	IF @Prime <> 0
	BEGIN
		PRINT @Counter
	END

END




EXEC sp_PrimeGen  @Limit = 10



DROP PROC sp_PrimeGen

GO



--DECLARE @TESTVALUE BIGINT = 233
--DECLARE @DIVISOR BIGINT = 2
--DECLARE @PRIME BIT = 1

--WHILE @DIVISOR < (@TESTVALUE / 2)
--BEGIN
--	IF (@TESTVALUE % @DIVISOR = 0)  -- If the remainder of the two divided (modulus) is 0.
--	BEGIN
--		PRINT 'The number is not prime. It is divisible by ' + CAST(@DIVISOR AS VARCHAR(10))
--		SET @PRIME = 0
--		BREAK	
--	END
--	SET @DIVISOR = @DIVISOR + 1
--END	

--IF @PRIME <> 0
--	PRINT CAST(@TESTVALUE AS VARCHAR(10)) + ' is a prime number.'








--create table prime (primeno bigint)
--declare @counter bigint
--set @counter = 2
--while @counter < 1000000
--begin
--if not exists(select top 1 primeno from prime where @counter % primeno = 0 )
--	insert into prime 
--	select @counter
--	set @counter = @counter + 1
--end

--select * from prime order by 1