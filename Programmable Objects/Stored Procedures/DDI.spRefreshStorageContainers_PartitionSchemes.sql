IF OBJECT_ID('[DDI].[spRefreshStorageContainers_PartitionSchemes]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshStorageContainers_PartitionSchemes];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshStorageContainers_PartitionSchemes]
    @DatabaseName SYSNAME,
	@PartitionFunctionName SYSNAME = NULL,
	@Debug BIT = 0

AS

/*
	EXEC DDI.spRefreshStorageContainers_PartitionSchemes
		@Debug = 1
*/

DECLARE @CreatePartitionSchemeSQL NVARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10)

SELECT @CreatePartitionSchemeSQL += CreatePartitionSchemeSQL + CHAR(13) + CHAR(10)
FROM DDI.vwPartitionFunctions
WHERE PartitionFunctionName = CASE WHEN @PartitionFunctionName IS NULL THEN PartitionFunctionName ELSE @PartitionFunctionName END

IF @Debug = 1
BEGIN
	PRINT @CreatePartitionSchemeSQL
END
ELSE
BEGIN
	EXEC sp_executesql @CreatePartitionSchemeSQL;  
END


GO
