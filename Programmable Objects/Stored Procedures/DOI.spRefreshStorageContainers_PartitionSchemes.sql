
GO

IF OBJECT_ID('[DOI].[spRefreshStorageContainers_PartitionSchemes]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshStorageContainers_PartitionSchemes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshStorageContainers_PartitionSchemes]
    @DatabaseName SYSNAME,
	@PartitionFunctionName SYSNAME = NULL,
	@Debug BIT = 0

AS

/*
	EXEC DOI.spRefreshStorageContainers_PartitionSchemes
		@Debug = 1
*/
BEGIN TRY
	DECLARE @CreatePartitionSchemeSQL NVARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10),
			@DropPartitionSchemeSQL NVARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10)


		SET @CreatePartitionSchemeSQL += (	SELECT CreatePartitionSchemeSQL + CHAR(13) + CHAR(10)
											FROM DOI.vwPartitionSchemes
											WHERE PartitionFunctionName = CASE WHEN @PartitionFunctionName IS NOT NULL THEN @PartitionFunctionName ELSE PartitionFunctionName END 
											FOR XML PATH, TYPE).value('.', 'varchar(max)')

		SET @DropPartitionSchemeSQL += (	SELECT DropPartitionSchemeSQL + CHAR(13) + CHAR(10)
											FROM DOI.vwPartitionSchemes
											WHERE PartitionFunctionName = CASE WHEN @PartitionFunctionName IS NOT NULL THEN @PartitionFunctionName ELSE PartitionFunctionName END 
											FOR XML PATH, TYPE).value('.', 'varchar(max)')

	IF @Debug = 1
	BEGIN
		PRINT @DropPartitionSchemeSQL
		PRINT @CreatePartitionSchemeSQL
	END
	ELSE
	BEGIN
		EXEC sp_executesql @DropPartitionSchemeSQL;
		EXEC sp_executesql @CreatePartitionSchemeSQL;  
	END
END TRY
BEGIN CATCH
	THROW;
END CATCH

GO