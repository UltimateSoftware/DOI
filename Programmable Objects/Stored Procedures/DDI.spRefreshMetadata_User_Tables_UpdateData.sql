IF OBJECT_ID('[DDI].[spRefreshMetadata_User_Tables_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Tables_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--EXEC DDI.spForeignKeysAdd
--    @ForMetadataTablesOnly = 1,
--	@ReferencedSchemaName	= 'DDI',
--	@ReferencedTableName	= 'Tables',
--    @UseExistenceCheck  = 1
--GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_Tables_UpdateData]

AS

UPDATE T
SET ColumnListNoTypes = DDI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'INSERT', 1, NULL, NULL),
	ColumnListWithTypes = DDI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'CREATETABLE', 1, NULL, NULL),
	UpdateColumnList = DDI.fnGetColumnListForTable (T.SchemaName, T.TableName, 'UPDATE', 1, 'PT', 'T'),
    NewPartitionedPrepTableName = TableName + '_NewPartitionedTableFromPrep',
    Storage_Actual = DS_Actual.name,
    StorageType_Actual = DS_Actual.type_desc,
    PKColumnList = DDI.fnGetPKColumnListForTable(T.DatabaseName, T.SchemaName, T.TableName),
    PKColumnListJoinClause = DDI.fnGetJoinClauseForTable(T.DatabaseName, T.SchemaName, T.TableName, 1, 'T', 'PT')
FROM DDI.Tables T
    INNER JOIN DDI.SysDatabases d ON T.DatabaseName = d.name
    INNER JOIN DDI.SysTables T2 ON T2.database_id = d.database_id
        AND T.TableName = T2.name
    INNER JOIN DDI.SysSchemas s ON s.name = T.SchemaName
    INNER JOIN DDI.SysIndexes I ON d.database_id = i.database_id
        AND T2.object_id = I.object_id
        AND I.type_desc IN ('CLUSTERED', 'HEAP')
    INNER JOIN DDI.SysDataSpaces DS_Actual ON i.database_id = DS_Actual.database_id
        AND i.data_space_id = DS_Actual.data_space_id

UPDATE T
SET PartitionFunctionName = PF.PartitionFunctionName
FROM DDI.Tables T
    LEFT JOIN DDI.PartitionFunctions PF ON PF.PartitionSchemeName = T.Storage_Actual

UPDATE T
SET StorageType_Desired = DS_Desired.type_desc
FROM DDI.Tables T
    INNER JOIN DDI.SysDataSpaces DS_Desired ON T.Storage_Desired = DS_Desired.name

UPDATE T
SET T.DSTriggerSQL = DSTrigger.DSTriggerSQL
FROM DDI.Tables T
	CROSS APPLY(SELECT STUFF((  SELECT PT.PrepTableTriggerSQLFragment
								FROM DDI.vwTables_PrepTables PT
								WHERE PT.SchemaName = T.SchemaName
									AND PT.TableName = T.TableName
								FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)'), 1, 1, '')) DSTrigger(DSTriggerSQL)


GO
