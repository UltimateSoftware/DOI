-- <Migration ID="d986aad9-0276-4deb-a7c0-65eb1d98ad69" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

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
SET Storage_Desired = CASE WHEN PF.PartitionFunctionName IS NOT NULL THEN PF.PartitionSchemeName ELSE 'PRIMARY' END,
    StorageType_Desired = CASE WHEN PF.PartitionFunctionName IS NOT NULL THEN 'PARTITION_SCHEME' ELSE 'ROWS_FILEGROUP' END
FROM DOI.Tables T
    LEFT JOIN DOI.PartitionFunctions PF ON PF.DatabaseName = T.DatabaseName
        AND T.PartitionFunctionName = PF.PartitionFunctionName
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 

UPDATE T
SET     [TableHasOldBlobColumns] = COALESCE(BC.HasBlobColumns, 0)
FROM DOI.Tables T
    OUTER APPLY (   SELECT 1 AS HasBlobColumns
                    FROM DOI.fnOldBlobColumns(T.DatabaseName, T.SchemaName, T.TableName)) BC


UPDATE T
SET ColumnListNoTypes = DOI.fnGetColumnListForTable (@DatabaseName, T.SchemaName, T.TableName, 'INSERT', 1, NULL, NULL),
	ColumnListWithTypes = DOI.fnGetColumnListForTable (@DatabaseName, T.SchemaName, T.TableName, 'CREATETABLE', 1, NULL, NULL),
	UpdateColumnList = DOI.fnGetColumnListForTable (@DatabaseName, T.SchemaName, T.TableName, 'UPDATE', 1, 'PT', 'T'),
    NewPartitionedPrepTableName = CASE WHEN T.IntendToPartition = 1 THEN TableName + '_NewPartitionedTableFromPrep' ELSE NULL END,
    Storage_Actual = DS_Actual.name,
    StorageType_Actual = DS_Actual.type_desc,
    PKColumnList = DOI.fnGetPKColumnListForTable(T.DatabaseName, T.SchemaName, T.TableName),
    PKColumnListJoinClause = DOI.fnGetJoinClauseForTable(T.DatabaseName, T.SchemaName, T.TableName, 1, 'T', 'PT'),
    ColumnListForDataSynchTriggerSelect =   DOI.fnGetDataSynchTriggerColumnSelectListForTable(T.DatabaseName, T.SchemaName, T.TableName, 1),
    ColumnListForDataSynchTriggerUpdate =   DOI.fnGetDataSynchTriggerColumnUpdateListForTable(T.DatabaseName, T.SchemaName, T.TableName, 1),
    ColumnListForDataSynchTriggerInsert =   DOI.fnGetDataSynchTriggerColumnInsertListForTable(T.DatabaseName, T.SchemaName, T.TableName, 1)


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


GO