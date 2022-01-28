IF OBJECT_ID('[DOI].[vwExchangeTableNonPartitioned_Tables_NewTable_Triggers]') IS NOT NULL
	DROP VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_NewTable_Triggers];

GO


CREATE     VIEW [DOI].[vwExchangeTableNonPartitioned_Tables_NewTable_Triggers]

/*
	select *
	from DOI.[vwExchangeTableNonPartitioned_Tables_NewTable_Triggers]
    where tablename = 'EmpHJob'
 */ 
AS

SELECT	T.DatabaseName,
		T.SchemaName,
		T.TableName,
		TR.name AS TriggerName,
		TR.is_disabled,
		TR.is_instead_of_trigger,
		TR.type_desc,
		1 AS IsNewTable,
        SQ.definition AS CreateTriggerSQL,
		'DROP TRIGGER IF EXISTS ' + T.SchemaName + '.' + TR.name + ';' + CHAR(13) + CHAR(10) AS DropTriggerSQL,
		ROW_NUMBER() OVER(PARTITION BY T.SchemaName, T.TableName ORDER BY T.SchemaName, T.TableName, TR.name) AS RowNum
FROM (	SELECT DatabaseName
                ,SchemaName
				,TableName
				,TableName + '_NewTable' AS NewTableName
				,'_NewTable' AS NewTableNameSuffix
				,ColumnListWithTypes
				,ColumnListNoTypes
				,UpdateColumnList
    			,PKColumnList
				,PKColumnListJoinClause
				,Storage_Desired
				,StorageType_Desired
                ,SPACE(0) AS NewTableFilegroup
		FROM DOI.Tables
		WHERE IntendToPartition = 0) T
	INNER JOIN DOI.SysDatabases D ON D.name = T.DatabaseName
	INNER JOIN DOI.SysSchemas S ON S.database_id = D.database_id
		AND S.name = T.SchemaName
	INNER JOIN DOI.SysTables T2 ON T2.database_id = D.database_id
		AND T2.name = T.TableName
    INNER JOIN DOI.SysTriggers TR ON TR.database_id = T2.database_id
		AND TR.parent_id = T2.object_id
    INNER JOIN DOI.SysSqlModules SQ ON SQ.database_id = TR.database_id
		AND SQ.object_id = TR.object_id
GO