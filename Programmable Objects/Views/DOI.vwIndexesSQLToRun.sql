-- <Migration ID="5048c6a4-4a49-46da-b2fd-8dc1bacfaa78" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[DOI].[vwIndexesSQLToRun]') IS NOT NULL
	DROP VIEW [DOI].[vwIndexesSQLToRun];

GO
CREATE   VIEW DOI.[vwIndexesSQLToRun]

AS
/*
1. PKs that are drop/recreated, create as unique with drop_existing, create new pk, drop uq index.
2. rest of operations as normal


*/
SELECT *
FROM (--drop/recreates
		SELECT	I.DatabaseName,
				I.SchemaName, 
				I.TableName, 
				I.IndexName, 
				I.IndexUpdateType AS OriginalIndexUpdateType,
				I.IndexUpdateType,
				N.RowNum,
				CASE N.RowNum
					WHEN 1 THEN CASE 
									WHEN I.IsPrimaryKey_Desired = 1 
									THEN I.DropReferencingFKs --CREATE UNIQUE INDEX INSTEAD OF PK, SINCE YOU CAN'T HAVE 2 PKs ON A TABLE.
									ELSE '' --nothing to do here
								END
					WHEN 2 THEN CASE 
									WHEN I.IsPrimaryKey_Desired = 1 
									THEN I.CreatePKAsUniqueIndexSQL --RECREATE PK CONSTRAINT AS UQ, SINCE YOU CAN'T HAVE 2 PKs ON A TABLE.  This is a temporary measure, so the table keeps enforcing uniqueness.
									ELSE '' --nothing to do here
								END
					WHEN 3 THEN CASE 
									WHEN I.IsPrimaryKey_Desired = 1 
									THEN I.CreateStatement --PK has been dropped by above command, so recreate it here.
									ELSE '' --nothing to do here
								END
					WHEN 4 THEN CASE 
									WHEN I.IsPrimaryKey_Desired = 1 
									THEN I.DropPKAsUniqueIndexSQL --drop temporary UQ.
									ELSE '' --nothing to do here
								END
					WHEN 5 THEN CASE
									WHEN I.IsPrimaryKey_Desired = 1
									THEN I.CreateReferencingFKs
									ELSE '' --nothing to do here
								END 
					ELSE ''
				END AS CurrentSQLToExecute,
				0 AS PartitionNumber,
				I.IndexSizeMB_Actual
		FROM DOI.vwIndexes I
			CROSS JOIN DOI.fnNumberTable(5) N
		WHERE I.IsPrimaryKey_Desired = 1
			AND I.IndexUpdateType = 'CreateDropExisting'

		--rest of index-level updates
		UNION ALL
		SELECT	I.DatabaseName,
				I.SchemaName, 
				I.TableName, 
				I.IndexName, 
				I.IndexUpdateType AS OriginalIndexUpdateType,
				CASE 
					WHEN I.IndexUpdateType = 'Delete'
					THEN 'Delete'
					WHEN I.IndexUpdateType = 'CreateMissing'
					THEN 'Create Index'
					WHEN I.IndexUpdateType = 'CreateDropExisting'
					THEN 'CreateDropExisting'
					WHEN I.IndexUpdateType LIKE 'Alter%' 
					THEN 'Alter Index'
					WHEN I.IndexUpdateType = 'None' 
					THEN 'None'
					ELSE ''
				END AS IndexUpdateType,
				1 AS RowNum,
				CASE I.IndexUpdateType
					WHEN 'Delete'
					THEN I.DropStatement
					WHEN 'CreateMissing'
					THEN I.CreateStatement
					WHEN 'CreateDropExisting'
					THEN I.CreateDropExistingStatement
					WHEN 'AlterRebuild'
					THEN	CASE
								WHEN I.IndexType = 'ColumnStore' 
								THEN I.CreateDropExistingStatement
								ELSE	CASE 
											WHEN I.IndexType = 'RowStore' AND I.IndexHasLOBColumns = 1
											THEN I.CreateDropExistingStatement
											ELSE I.AlterRebuildStatement
										END 
							END 
					WHEN 'AlterReorganize'
					THEN I.AlterReorganizeStatement
					WHEN 'AlterSet'
					THEN I.AlterSetStatement
					ELSE ''
				END AS CurrentSQLToExecute,
				0 AS PartitionNumber,
				I.IndexSizeMB_Actual
		FROM DOI.vwIndexes I
			CROSS JOIN DOI.fnNumberTable(3) N
		WHERE I.IndexUpdateType <> 'None'

		--partition-level updates
		UNION ALL
		SELECT	IP.DatabaseName,
				IP.SchemaName, 
				IP.TableName, 
				IP.IndexName, 
				IP.PartitionUpdateType,
				IP.PartitionUpdateType,
				1 AS RowNum,
				CASE IP.PartitionUpdateType
					WHEN 'AlterRebuild-PartitionLevel'
					THEN IP.AlterRebuildStatement
					WHEN 'AlterReorganize-PartitionLevel'
					THEN IP.AlterReorganizeStatement
					ELSE ''
				END AS CurrentSQLToExecute,
				IP.PartitionNumber,
				IP.TotalIndexPartitionSizeInMB
		FROM DOI.vwIndexPartitions IP 
		WHERE IP.PartitionUpdateType <> 'None') U
WHERE U.CurrentSQLToExecute <> ''
GO