
GO

IF OBJECT_ID('[DOI].[vwPartitioning_Tables_PrepTables_Partitions]') IS NOT NULL
	DROP VIEW [DOI].[vwPartitioning_Tables_PrepTables_Partitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [DOI].[vwPartitioning_Tables_PrepTables_Partitions]
AS

/*
	select *
	from DOI.vwPartitioning_Tables_PrepTables_Partitions
	WHERE parenttablename = 'Pays' 
	order by PartitionNumber
*/ 
SELECT	PTNonPartitioned.DatabaseName,
		PTNonPartitioned.SchemaName,
		PTNonPartitioned.TableName AS ParentTableName,
		PTPartitioned.PartitionFunctionName,
		PTPartitioned.NewPartitionedPrepTableName,
		PTNonPartitioned.PrepTableName AS UnPartitionedPrepTableName,
		PTNonPartitioned.BoundaryValue AS PartitionFunctionValue,
		PTNonPartitioned.IsNewPartitionedTable,
		ISNULL(PTNonPartitioned.NextBoundaryValue, '9999-12-31') AS NextPartitionFunctionValue,
			'
IF EXISTS(	SELECT ''True'' 
			FROM ' + PTPartitioned.SchemaName + '.' + PTPartitioned.PrepTableName + ' 
			WHERE $PARTITION.' + PTPartitioned.PartitionFunctionName + '(' + PTPartitioned.PartitionColumn + ') = ' + CAST(PTNonPartitioned.PartitionNumber AS VARCHAR(6)) + ')
BEGIN
	TRUNCATE TABLE ' + PTPartitioned.SchemaName + '.' + PTPartitioned.PrepTableName + ' WITH (PARTITIONS (' + CAST(PTNonPartitioned.PartitionNumber AS VARCHAR(6)) + '))
END' AS PartitionDataValidationSQL,
		'
ALTER TABLE ' + PTNonPartitioned.SchemaName + '.' + PTNonPartitioned.PrepTableName + ' SWITCH TO ' +  PTPartitioned.SchemaName + '.' + PTPartitioned.PrepTableName + ' PARTITION ' + CAST(PTNonPartitioned.PartitionNumber AS VARCHAR(5)) + '' + CHAR(13) + CHAR(10) 
AS PartitionSwitchSQL,
		'
DROP TABLE ' + PTNonPartitioned.SchemaName + '.' + PTNonPartitioned.PrepTableName 
AS DropTableSQL,

		PTNonPartitioned.PartitionNumber
FROM DOI.vwPartitioning_Tables_PrepTables PTNonPartitioned
	INNER JOIN DOI.vwPartitioning_Tables_NewPartitionedTable PTPartitioned ON PTNonPartitioned.DatabaseName = PTPartitioned.DatabaseName
		AND PTNonPartitioned.SchemaName = PTPartitioned.SchemaName
		AND PTPartitioned.TableName = PTNonPartitioned.TableName
WHERE PTNonPartitioned.IsNewPartitionedTable = 0

GO