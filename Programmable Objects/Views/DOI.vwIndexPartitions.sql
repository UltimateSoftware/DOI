
GO

IF OBJECT_ID('[DOI].[vwIndexPartitions]') IS NOT NULL
	DROP VIEW [DOI].[vwIndexPartitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   VIEW [DOI].[vwIndexPartitions]
AS

/*
	SELECT * 
    FROM DOI.vwIndexPartitions 
    ORDER BY SchemaName, TableName, IndexName, PartitionNumber
*/
SELECT	SchemaName,
		TableName,
		IndexName, 
		PartitionNumber, 
		TotalIndexPartitionSizeInMB, 
		DataFileName, 
		DriveLetter,
		NumRows, 
		TotalPages,
		Fragmentation,
		CASE
			WHEN Fragmentation > 30
				OR OptionDataCompression <> OptionDataCompression --certain options or frag over 30%.
			THEN 'AlterRebuild-PartitionLevel' --can be done on a partition level
			WHEN (OptionDataCompression = OptionDataCompression)--NO OPTIONS CHANGES, 5-30% frag, needs LOB compaction
				AND Fragmentation BETWEEN 5 AND 30
			THEN 'AlterReorganize-PartitionLevel' --this always happens online, can be done on a partition level
			ELSE 'None'
		END AS PartitionUpdateType,
		PartitionType,
		OptionDataCompression,
		'
TRUNCATE TABLE ' + SchemaName + '.' + TableName + 'WITH (PARTITIONS (' + CAST(PartitionNumber AS VARCHAR(5)) + '))' AS TruncateStatement,
'USE ' + DatabaseName + ';
ALTER INDEX ' + IndexName + ' ON ' + SchemaName + '.' + TableName + CHAR(13) + CHAR(10) + 
'	REBUILD PARTITION = ' + CAST(PartitionNumber AS VARCHAR(5)) + CHAR(13) + CHAR(10) + 
'		WITH (	' + CASE WHEN PartitionType = 'RowStore' THEN '
				SORT_IN_TEMPDB = ON,' ELSE '' END + '
				ONLINE = ' + CASE WHEN PartitionType = 'RowStore' THEN 'ON(WAIT_AT_LOW_PRIORITY (MAX_DURATION = 0 MINUTES, ABORT_AFTER_WAIT = NONE))' ELSE 'OFF' END + ',
				MAXDOP = 0,
				DATA_COMPRESSION = ' + OptionDataCompression COLLATE DATABASE_DEFAULT + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) 
AS AlterRebuildStatement
				,'
ALTER INDEX ' + IndexName + ' ON ' + SchemaName + '.' + TableName + CHAR(13) + CHAR(10) + 
'	REORGANIZE PARTITION = ' + CAST(PartitionNumber AS VARCHAR(5)) + CHAR(13) + CHAR(10) + 
'		WITH (	LOB_COMPACTION = ON)' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) AS AlterReorganizeStatement
--select count(*)
FROM DOI.IndexPartitionsRowStore 


GO
