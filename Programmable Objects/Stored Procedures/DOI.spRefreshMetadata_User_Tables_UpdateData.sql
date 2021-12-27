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
SET [TableHasIdentityColumn] = ISNULL(IC.HasIdentityColumn, 0)
FROM DOI.Tables T
    OUTER APPLY (   SELECT 1 HasIdentityColumn
                    FROM DOI.SysDatabases D 
                        INNER JOIN DOI.SysTables ST ON d.database_id = ST.database_id
                        INNER JOIN DOI.SysSchemas S ON ST.schema_id = S.schema_id
                        INNER JOIN DOI.SysIdentityColumns IC ON D.database_id = IC.database_id
                            AND ST.object_id = IC.object_id
                    WHERE T.DatabaseName = D.NAME
                        AND T.SchemaName = S.name
                        AND T.TableName = ST.name) IC

--4 updates, splitting off the ones who don't need sysindexes from the ones who do
UPDATE T
SET NewPartitionedPrepTableName = CASE WHEN T.IntendToPartition = 1 THEN TableName + '_NewPartitionedTableFromPrep' ELSE NULL END,
    Storage_Actual = DS_Actual.name,
    StorageType_Actual = DS_Actual.type_desc,
    PKColumnList_Desired = DOI.fnGetPKColumnListForTable_Desired(T.DatabaseName, T.SchemaName, T.TableName),
    PKColumnListJoinClause_Desired = DOI.fnGetJoinClauseForTable_Desired(T.DatabaseName, T.SchemaName, T.TableName, 1, 'T', 'PT')
FROM DOI.Tables T
    INNER JOIN DOI.SysDatabases d ON T.DatabaseName = d.name
    INNER JOIN DOI.SysTables T2 ON T2.database_id = d.database_id
        AND T.TableName = T2.name
    INNER JOIN DOI.SysSchemas s ON s.database_id = d.database_id
        AND s.name = T.SchemaName
    INNER JOIN DOI.SysIndexes I ON d.database_id = i.database_id
        AND T2.object_id = I.object_id
        AND I.type_desc IN ('CLUSTERED', 'HEAP', 'CLUSTERED COLUMNSTORE')
    INNER JOIN DOI.SysDataSpaces DS_Actual ON i.database_id = DS_Actual.database_id
        AND i.data_space_id = DS_Actual.data_space_id
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 

--1 sec
UPDATE T
SET PKColumnList = REPLACE(PKCL.PKColumnList, '&#x0D;', SPACE(0)),
    PKColumnListJoinClause = REPLACE(JC.JoinClause, '&#x0D;', SPACE(0))
FROM DOI.Tables T
    INNER JOIN DOI.SysDatabases d ON T.DatabaseName = d.name
    INNER JOIN DOI.SysTables T2 ON T2.database_id = d.database_id
        AND T.TableName = T2.name
    INNER JOIN DOI.SysSchemas s ON s.database_id = t2.database_id
		AND s.schema_id = t2.schema_id
        AND s.name = T.SchemaName
    INNER JOIN DOI.SysIndexes I ON d.database_id = i.database_id
        AND T2.object_id = I.object_id
		AND i.is_primary_key = 1
	CROSS APPLY (	SELECT STUFF((	SELECT ',' + c.name
									FROM DOI.SysIndexColumns ic 
										INNER JOIN DOI.SysColumns c ON c.database_id = ic.database_id
											AND c.column_id = ic.column_id
											AND c.object_id = ic.object_id
									WHERE ic.database_id = i.database_id
										AND ic.object_id = i.object_id
										AND ic.index_id = i.index_id
									ORDER BY ic.key_ordinal ASC
									FOR XML PATH('')), 1, 1, '')) PKCL(PKColumnList)
	CROSS APPLY (	SELECT STUFF((	SELECT CHAR(9) + N'AND T.' + c.name + N' = PT.' + c.name + NCHAR(13) + NCHAR(10)
									FROM DOI.SysIndexColumns ic 
										INNER JOIN DOI.SysColumns c ON c.database_id = ic.database_id
											AND c.column_id = ic.column_id
											AND c.object_id = ic.OBJECT_ID
									WHERE ic.database_id = i.database_id
										AND ic.index_id = i.index_id
										AND ic.object_id = i.object_id
									ORDER BY ic.key_ordinal ASC
									FOR XML PATH ('')), 1, 1, '')) JC(JoinClause)
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 

--6 seconds
UPDATE T
SET ColumnListNoTypes = REPLACE(ICL.InsertColumnList, '&#x0D;', SPACE(0)),
	ColumnListWithTypes = REPLACE(CTCL.CreateTableColumnList, '&#x0D;', SPACE(0)),
    ColumnListWithTypesNoIdentityProperty = REPLACE(CTCLNIP.CreateTableColumnListNoIdentityProperty, '&#x0D;', SPACE(0)),
	UpdateColumnList = REPLACE(UCL.UpdateColumnList, '&#x0D;', SPACE(0))
FROM DOI.Tables T
    INNER JOIN DOI.SysDatabases d ON T.DatabaseName = d.name
    INNER JOIN DOI.SysTables T2 ON T2.database_id = d.database_id
        AND T.TableName = T2.name
    INNER JOIN DOI.SysSchemas s ON s.database_id = t2.database_id
		AND s.schema_id = t2.schema_id
        AND s.name = T.SchemaName
	CROSS APPLY (	SELECT STUFF((	SELECT ',' + CHAR(9) + QUOTENAME(c.name, ']') + SPACE(1) + NCHAR(13) + NCHAR(10)
									FROM DOI.SysColumns c 
									WHERE c.database_id = T2.database_id
										AND c.object_id = t2.object_id
										AND C.is_computed = 0
									ORDER BY c.column_id
									FOR XML PATH ('')), 1, 1, '')) ICL(InsertColumnList)
	CROSS APPLY (	SELECT STUFF((	SELECT CHAR(9) + QUOTENAME(c.name, ']') + SPACE(1) +
										UPPER(ty.name) + 
											CASE 
												WHEN ty.NAME LIKE '%CHAR%' 
												THEN N'(' + CASE WHEN c.max_length = -1 THEN N'MAX' ELSE CAST(CASE WHEN c.user_type_id IN (231, 239) THEN c.max_length/2 ELSE c.max_length END AS NVARCHAR(10)) END  + N')' 
												WHEN ty.NAME IN ('DECIMAL', 'NUMERIC')
												THEN N'(' + CAST(c.precision AS NVARCHAR(10)) + ', ' + CAST(c.scale AS NVARCHAR(10)) + N')' 
												WHEN ty.name LIKE '%INT'
												THEN CASE WHEN c.is_identity = 1 THEN N' IDENTITY(' + CAST(c.identity_seed_value AS NVARCHAR(10)) + N', ' + CAST(c.identity_incr_value AS NVARCHAR(10)) + N')' ELSE N'' END
												ELSE N'' 
											END + 
											CASE c.is_nullable WHEN 0 THEN N' NOT' ELSE SPACE(0) END + N' NULL' +
											',' + NCHAR(13) + NCHAR(10)
									FROM DOI.SysColumns c
										INNER JOIN DOI.SysTypes ty ON c.database_id = ty.database_id
											AND c.user_type_id = ty.user_type_id
									WHERE c.database_id = t2.database_id
										AND c.object_id = t2.object_id
										AND C.is_computed = 0
									ORDER BY c.column_id
									FOR XML PATH ('')), 1, 1, '')) CTCL(CreateTableColumnList)
	CROSS APPLY (	SELECT STUFF((	SELECT CHAR(9) + QUOTENAME(c.name, ']') + SPACE(1) +
										UPPER(ty.name) + 
											CASE 
												WHEN ty.NAME LIKE '%CHAR%' 
												THEN N'(' + CASE WHEN c.max_length = -1 THEN N'MAX' ELSE CAST(CASE WHEN c.user_type_id IN (231, 239) THEN c.max_length/2 ELSE c.max_length END AS NVARCHAR(10)) END  + N')' 
												WHEN ty.NAME IN ('DECIMAL', 'NUMERIC')
												THEN N'(' + CAST(c.precision AS NVARCHAR(10)) + ', ' + CAST(c.scale AS NVARCHAR(10)) + N')' 
												ELSE N'' 
											END + 
											CASE c.is_nullable WHEN 0 THEN N' NOT' ELSE SPACE(0) END + N' NULL,' + NCHAR(13) + NCHAR(10)
									FROM DOI.SysColumns c 
										INNER JOIN DOI.SysTypes ty ON c.database_id = ty.database_id
											AND c.user_type_id = ty.user_type_id
									WHERE c.database_id = t2.database_id
										AND c.object_id = t2.object_id
										AND C.is_computed = 0
									ORDER BY c.column_id
									FOR XML PATH ('')), 1, 1, '')) CTCLNIP(CreateTableColumnListNoIdentityProperty)
	CROSS APPLY (	SELECT STUFF((	SELECT CHAR(9) + N'PT.' + QUOTENAME(c.name, ']') + N' = T.' + QUOTENAME(c.name, ']') + N','+ NCHAR(13) + NCHAR(10)
									FROM DOI.SysColumns c 
									WHERE c.database_id = t2.database_id
										AND c.object_id = t2.object_id
										AND C.is_computed = 0
									ORDER BY c.column_id
									FOR XML PATH ('')), 1, 1, '')) UCL(UpdateColumnList)
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 

--3 seconds
UPDATE T
SET ColumnListForDataSynchTriggerSelect = REPLACE(FDSTSCL.ColumnListForDataSynchTriggerSelect, '&#x0D;', SPACE(0)),
    ColumnListForDataSynchTriggerUpdate = REPLACE(FDSTUCL.ColumnListForDataSynchTriggerUpdate, '&#x0D;', SPACE(0)),
    ColumnListForDataSynchTriggerInsert = REPLACE(FDSTICL.ColumnListForDataSynchTriggerInsert, '&#x0D;', SPACE(0)),
    ColumnListForFinalDataSynchTriggerSelectForDelete = REPLACE(FDSTSCLFD.ColumnListForFinalDataSynchTriggerSelectForDelete, '&#x0D;', SPACE(0))
FROM DOI.Tables T
    INNER JOIN DOI.SysDatabases d ON T.DatabaseName = d.name
    INNER JOIN DOI.SysTables T2 ON T2.database_id = d.database_id
        AND T.TableName = T2.name
    INNER JOIN DOI.SysSchemas s ON s.database_id = t2.database_id
		AND s.schema_id = t2.schema_id
        AND s.name = T.SchemaName
	CROSS APPLY (	SELECT STUFF((	SELECT ',' + CHAR(9) + 
										CASE
											WHEN TY.name IN ('TEXT', 'NTEXT', 'IMAGE')--Old BLOB columns cannot be selected from inserted and deleted tables.
											THEN N'PT.'
											ELSE N'T.'
										END + QUOTENAME(c.name, ']') + SPACE(1) + NCHAR(13) + NCHAR(10)
									FROM DOI.SysColumns c 
										INNER JOIN DOI.SysTypes ty ON c.database_id = ty.database_id
											AND c.user_type_id = ty.user_type_id
									WHERE c.database_id = t2.database_id
										AND c.object_id = t2.object_id
										AND ty.name <> N'TIMESTAMP'
									ORDER BY c.column_id
									FOR XML PATH('')), 1, 1, '')) FDSTSCL(ColumnListForDataSynchTriggerSelect)
	CROSS APPLY (	SELECT STUFF((	SELECT ',' + CHAR(9) + N'PT.' + QUOTENAME(c.name, ']') + N' = ' + 
										CASE
											WHEN TY.name IN ('TEXT', 'NTEXT', 'IMAGE')--Old BLOB columns cannot be selected from inserted and deleted tables.
											THEN N'ST.'
											ELSE N'T.' 
										END + QUOTENAME(c.name, ']') + SPACE(1) + NCHAR(13) + NCHAR(10)
									FROM DOI.SysColumns c 
										INNER JOIN DOI.SysTypes ty ON c.database_id = ty.database_id
											AND c.user_type_id = ty.user_type_id
									WHERE c.database_id = t2.database_id
										AND c.object_id = t2.object_id
										AND ty.name <> N'TIMESTAMP'
										AND c.is_identity = 0
									ORDER BY c.column_id
									FOR XML PATH('')), 1, 1, ''))FDSTUCL(ColumnListForDataSynchTriggerUpdate)
	CROSS APPLY (	SELECT STUFF((	SELECT ',' + CHAR(9) + QUOTENAME(c.name, ']') + SPACE(1) + NCHAR(13) + NCHAR(10)
									FROM DOI.SysColumns c 
										INNER JOIN DOI.SysTypes ty ON c.database_id = ty.database_id
											AND c.user_type_id = ty.user_type_id
									WHERE c.database_id = t2.database_id
										AND c.object_id = t2.object_id
										AND C.is_computed = 0
										AND ty.name <> N'TIMESTAMP'
									ORDER BY c.column_id
									FOR XML PATH('')), 1, 1, '')) FDSTICL(ColumnListForDataSynchTriggerInsert)
	CROSS APPLY (	SELECT STUFF((	SELECT ',' + CHAR(9) +  
										CASE
											WHEN TY.name IN ('TEXT', 'NTEXT', 'IMAGE') --Old BLOB columns cannot be selected from inserted and deleted tables.
											THEN N'NULL'
											ELSE N'T.' + QUOTENAME(c.name, ']') + SPACE(1)
										END + N' ' + NCHAR(13) + NCHAR(10)
									FROM DOI.SysColumns c 
										INNER JOIN DOI.SysTypes ty ON c.database_id = ty.database_id
											AND c.user_type_id = ty.user_type_id
									WHERE c.database_id = t2.database_id
										AND c.object_id = t2.object_id
										AND ty.name <> N'TIMESTAMP'
									ORDER BY c.column_id
									FOR XML PATH('')), 1, 1, '')) FDSTSCLFD(ColumnListForFinalDataSynchTriggerSelectForDelete)
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 


GO