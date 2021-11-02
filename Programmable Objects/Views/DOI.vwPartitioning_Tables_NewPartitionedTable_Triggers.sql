-- <Migration ID="272186f4-7737-473e-930c-b622a49bca27" />
GO
IF OBJECT_ID('[DOI].[vwPartitioning_Tables_NewPartitionedTable_Triggers]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitioning_Tables_NewPartitionedTable_Triggers];

GO


CREATE     VIEW [DOI].[vwPartitioning_Tables_NewPartitionedTable_Triggers]

/*
	select top 10 CreateViewForBCPSQL
	from DOI.[vwPartitioning_Tables_NewPartitionedTable_Triggers]
    where tablename = 'BAI2BANKTRANSACTIONS'
	order by tablename, partitionnumber
 */ 
AS

SELECT	*,
		1 AS IsNewPartitionedTable,
        s.definition AS TriggerSQL
FROM (	SELECT DatabaseName
                ,SchemaName
				,TableName
				,0 AS DateDiffs
				,TableName + '_NewPartitionedTableFromPrep' AS PrepTableName
				,'_NewPartitionedTableFromPrep' AS PrepTableNameSuffix
				,TableName + '_NewPartitionedTableFromPrep' AS NewPartitionedPrepTableName
				,PartitionFunctionName
				,'9999-12-31' AS NextBoundaryValue
				,'0001-01-01' AS BoundaryValue
				,ColumnListWithTypes
				,ColumnListNoTypes
				,UpdateColumnList
    			,PartitionColumn
    			,PKColumnList
				,PKColumnListJoinClause
				,Storage_Desired
				,StorageType_Desired
				,0 AS PartitionNumber
                ,SPACE(0) AS PrepTableFilegroup
		FROM DOI.Tables
		WHERE IntendToPartition = 1) T

    INNER JOIN DOI.SysTriggers TR ON T.DatabaseName = TR.D
    INNER JOIN DOI.SysSqlModules S ON S.database_id = TR.database_id
		AND S.object_id = TR.object_id
GO


SELECT * FROM DOI.SysTriggers
--CREATE SYS.SQL_MODULES DOI TABLE
--CREATE SYNCH PROCESS FOR IT
--integrate new table synch into synch process
--JOIN TO THIS NEW TABLE HERE TO GET TRIGGER CODE.
