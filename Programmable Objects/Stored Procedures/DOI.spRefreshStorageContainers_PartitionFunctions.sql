USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshStorageContainers_PartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshStorageContainers_PartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshStorageContainers_PartitionFunctions]
    @DatabaseName SYSNAME,
	@PartitionFunctionName SYSNAME = NULL,
	@Debug BIT = 0

AS

/*
	EXEC DOI.spRefreshStorageContainers_PartitionFunctions
        @DatabaseName = 'PaymentReporting',
		@Debug = 1

EXEC [DOI].[spRefreshStorageContainers_PartitionFunctions] 
                            @DatabaseName = 'PaymentReporting',
                            @PartitionFunctionName = 'PfMonthlyUnitTest'
*/

BEGIN TRY

	IF NOT EXISTS(SELECT 'True' FROM DOI.PartitionFunctions WHERE PartitionFunctionName = CASE WHEN @PartitionFunctionName IS NOT NULL THEN @PartitionFunctionName ELSE PartitionFunctionName END)
	BEGIN
		RAISERROR('Invalid partition Function name.  Make sure it exists in DOI.PartitionFunctions table.', 16, 1)
	END


	DECLARE @CreatePartitionFunctionSQL NVARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10)


	SET @CreatePartitionFunctionSQL += (SELECT CreatePartitionFunctionSQL + CHAR(13) + CHAR(10)
	                                    FROM DOI.vwPartitionFunctions
	                                    WHERE PartitionFunctionName = CASE WHEN @PartitionFunctionName IS NOT NULL THEN @PartitionFunctionName ELSE PartitionFunctionName END 
                                        FOR XML PATH, TYPE).value('.', 'varchar(max)')

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
