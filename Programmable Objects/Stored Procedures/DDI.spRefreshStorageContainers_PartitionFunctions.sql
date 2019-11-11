IF OBJECT_ID('[DDI].[spRefreshStorageContainers_PartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshStorageContainers_PartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshStorageContainers_PartitionFunctions]
    @DatabaseName SYSNAME,
	@PartitionFunctionName SYSNAME = NULL,
	@Debug BIT = 0

AS

/*
	EXEC DDI.spRefreshStorageContainers_PartitionFunctions
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
