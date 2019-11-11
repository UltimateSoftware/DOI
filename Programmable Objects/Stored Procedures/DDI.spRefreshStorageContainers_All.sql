IF OBJECT_ID('[DDI].[spRefreshStorageContainers_All]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshStorageContainers_All];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshStorageContainers_All]

AS


SELECT '
	EXEC DDI.spRefreshStorageContainers_PartitionFunctions @DatabaseName = ''' + DatabaseName + '''
	EXEC DDI.spRefreshStorageContainers_FilegroupsAndFiles @DatabaseName = ''' + DatabaseName + '''
	EXEC DDI.spRefreshStorageContainers_PartitionSchemes   @DatabaseName = ''' + DatabaseName + ''''

FROM DDI.Databases

GO
