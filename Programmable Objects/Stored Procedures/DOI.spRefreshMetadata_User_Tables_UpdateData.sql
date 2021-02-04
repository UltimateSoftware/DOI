
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Tables_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Tables_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
    EXEC DOI.spRefreshMetadata_User_Tables_UpdateData
        @DatabaseName = 'DOIUnitTests'

*/

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_Tables_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

AS

UPDATE T
SET ColumnListNoTypes = DOI.fnGetColumnListForTable (@DatabaseName, T.SchemaName, T.TableName, 'INSERT', 1, NULL, NULL),
	ColumnListWithTypes = DOI.fnGetColumnListForTable (@DatabaseName, T.SchemaName, T.TableName, 'CREATETABLE', 1, NULL, NULL),
	UpdateColumnList = DOI.fnGetColumnListForTable (@DatabaseName, T.SchemaName, T.TableName, 'UPDATE', 1, 'PT', 'T'),
    NewPartitionedPrepTableName = CASE WHEN T.IntendToPartition = 1 THEN TableName + '_NewPartitionedTableFromPrep' ELSE NULL END,
    Storage_Actual = DS_Actual.name,
    StorageType_Actual = DS_Actual.type_desc,
    PKColumnList = DOI.fnGetPKColumnListForTable(T.DatabaseName, T.SchemaName, T.TableName),
    PKColumnListJoinClause = DOI.fnGetJoinClauseForTable(T.DatabaseName, T.SchemaName, T.TableName, 1, 'T', 'PT')
FROM DOI.Tables T
    INNER JOIN DOI.SysDatabases d ON T.DatabaseName = d.name
    INNER JOIN DOI.SysTables T2 ON T2.database_id = d.database_id
        AND T.TableName = T2.name
    INNER JOIN DOI.SysSchemas s ON s.database_id = d.database_id
        AND s.name = T.SchemaName
    INNER JOIN DOI.SysIndexes I ON d.database_id = i.database_id
        AND T2.object_id = I.object_id
        AND I.type_desc IN ('CLUSTERED', 'HEAP')
    INNER JOIN DOI.SysDataSpaces DS_Actual ON i.database_id = DS_Actual.database_id
        AND i.data_space_id = DS_Actual.data_space_id
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 


--UPDATE STORAGE DESIRED FOR PARTITIONED TABLES ONLY.
UPDATE T
SET Storage_Desired = PF.PartitionSchemeName,
    StorageType_Desired = 'PARTITION_SCHEME'
FROM DOI.Tables T
    INNER JOIN DOI.PartitionFunctions PF ON PF.DatabaseName = T.DatabaseName
        AND T.PartitionFunctionName = PF.PartitionFunctionName
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 

UPDATE T
SET T.DSTriggerSQL = DSTrigger.DSTriggerSQL
FROM DOI.Tables T
	CROSS APPLY(SELECT STUFF((  SELECT PT.PrepTableTriggerSQLFragment
								FROM DOI.vwPartitioning_Tables_PrepTables PT
								WHERE PT.SchemaName = T.SchemaName
									AND PT.TableName = T.TableName
								FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)'), 1, 1, '')) DSTrigger(DSTriggerSQL)
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 


GO