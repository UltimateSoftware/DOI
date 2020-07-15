USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[vwTables_PrepTables_Partitions]') IS NOT NULL
	DROP VIEW [DOI].[vwTables_PrepTables_Partitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [DOI].[vwTables_PrepTables_Partitions]
AS

/*
	select *
	from DOI.vwTables_PrepTables_Partitions
	WHERE parenttablename = 'Pays' 
	order by PartitionNumber
*/ 
SELECT	PTNonPartitioned.SchemaName,
		PTNonPartitioned.TableName AS ParentTableName,
		PTPartitioned.NewPartitionedPrepTableName,
		PTNonPartitioned.PrepTableName AS UnPartitionedPrepTableName,
		PTNonPartitioned.BoundaryValue AS PartitionFunctionValue,
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
FROM DOI.vwTables_PrepTables PTNonPartitioned
	INNER JOIN DOI.vwTables_PrepTables PTPartitioned ON PTNonPartitioned.SchemaName = PTPartitioned.SchemaName
		AND PTPartitioned.TableName = PTNonPartitioned.TableName
WHERE PTNonPartitioned.IsNewPartitionedPrepTable = 0
	AND PTPartitioned.IsNewPartitionedPrepTable = 1


GO
