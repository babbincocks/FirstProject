CREATE PROC sp_PrimeGen
(	
	 @Limit INT = '',
	@Counter INT = 2
)
AS
BEGIN
	DECLARE @Divider INT = 2
	DECLARE @Prime BIT = 1
	WHILE @Limit >= @Counter
		BEGIN
			
			WHILE @Divider <= (sqrt(@Counter))
				BEGIN
					IF  (@Counter % @Divider = 0)
						BEGIN 
							SET @Prime = 0
							BREAK
						END
						ELSE	 SET @Divider = @Divider + 1 
								
								
						
				END
		
			
		

	IF @Prime <> 0
	BEGIN
		PRINT @Counter
	END
	 
	SET @Counter = @Counter + 1
	SET @Prime = 1
	SET @Divider = 2	
		END
END
GO



EXEC sp_PrimeGen 256



--DROP PROC sp_PrimeGen

GO


--CREATE PROC sp_PrimeGen
--(	
--	 @Limit INT = ''
	
--)
--AS
--BEGIN
--DECLARE @TESTVALUE BIGINT = 1
--DECLARE @DIVISOR BIGINT = 2
--DECLARE @PRIME BIT = 1
----WHILE @TESTVALUE < @Limit
--BEGIN
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
--END
--IF @PRIME <> 0
--	PRINT CAST(@TESTVALUE AS VARCHAR(10)) + ' is a prime number.'

--END
--GO






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





--CREATE  proc sp_PrimeGen
--@no int  
--as   
--	declare @counter int  
--	set @counter =2  
--		begin  
--		while(@counter)<@no  
-- begin  
-- if(@no%@counter=0)  
--  begin  
--  select 'Not prime'  
--  return  
--  end  
--  set @counter=@counter+1  
-- end  
-- select 'prime'  
-- return  
--end  

--exec prime 10 