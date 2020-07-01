IF OBJECT_ID('[DOI].[spRefreshStorageContainers_All]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshStorageContainers_All];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshStorageContainers_All]

AS


SELECT '
	EXEC DOI.spRefreshStorageContainers_PartitionFunctions @DatabaseName = ''' + DatabaseName + '''
	EXEC DOI.spRefreshStorageContainers_FilegroupsAndFiles @DatabaseName = ''' + DatabaseName + '''
	EXEC DOI.spRefreshStorageContainers_PartitionSchemes   @DatabaseName = ''' + DatabaseName + ''''

FROM DOI.Databases

GO
