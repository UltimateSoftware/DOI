
GO

IF OBJECT_ID('[DOI].[spRefreshStorageContainers_All]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshStorageContainers_All];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshStorageContainers_All]
	@DatabaseName SYSNAME,
	@Debug BIT = 0

AS


	EXEC DOI.spRefreshStorageContainers_PartitionFunctions @DatabaseName			= @DatabaseName, @Debug = @Debug
	EXEC DOI.spRefreshStorageContainers_FilegroupsAndFiles @DatabaseName			= @DatabaseName, @Debug = @Debug
	EXEC DOI.spRefreshStorageContainers_PartitionSchemes   @DatabaseName			= @DatabaseName, @Debug = @Debug
	EXEC DOI.spRefreshStorageContainers_AddNewPartitionsToMetadata @DatabaseName	= @DatabaseName, @Debug = @Debug

GO