USE DDI
GO

CREATE OR ALTER PROCEDURE DDI.spPartitionFunctionCreate
    @DatabaseName SYSNAME,
	@PartitionFunctionName SYSNAME = NULL,
	@Debug BIT = 0

AS

/*
	EXEC DDI.spPartitionFunctionCreate
        @DatabaseName = 'PaymentReporting',
		@Debug = 1
*/

BEGIN TRY

	IF NOT EXISTS(SELECT 'True' FROM DDI.PartitionFunctions WHERE PartitionFunctionName = CASE WHEN @PartitionFunctionName IS NOT NULL THEN @PartitionFunctionName ELSE PartitionFunctionName END)
	BEGIN
		RAISERROR('Invalid partition Function name.  Make sure it exists in Utility.PartitionFunctions table.', 16, 1)
	END


	DECLARE @CreatePartitionFunctionSQL NVARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10)


	SELECT @CreatePartitionFunctionSQL += CreatePartitionFunctionSQL + CHAR(13) + CHAR(10)
	FROM DDI.vwPartitionFunctions
	WHERE PartitionFunctionName = CASE WHEN @PartitionFunctionName IS NOT NULL THEN @PartitionFunctionName ELSE PartitionFunctionName END 

	IF @Debug = 1
	BEGIN
		PRINT @CreatePartitionFunctionSQL
	END
	ELSE
	BEGIN
		EXEC sp_executesql @CreatePartitionFunctionSQL;  
	END
END TRY
BEGIN CATCH
	THROW;
END CATCH

GO

EXEC DDI.spPartitionFunctionCreate
    @DatabaseName = 'PaymentReporting',
	@Debug = 0
GO
