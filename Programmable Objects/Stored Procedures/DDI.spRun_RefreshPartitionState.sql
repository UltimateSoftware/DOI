IF OBJECT_ID('[DDI].[spRun_RefreshPartitionState]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRun_RefreshPartitionState];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRun_RefreshPartitionState]

AS

SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
SET QUOTED_IDENTIFIER ON

--DELETE ANY ROWS FOR TABLES THAT ARE NOT GOING TO BE PARTITIONED NOW
DELETE PS
FROM DDI.RefreshIndexes_PartitionState PS
WHERE NOT EXISTS(	SELECT 'True'
					FROM DDI.vwTables T
					WHERE T.SchemaName = PS.SchemaName
						AND T.TableName = PS.ParentTableName
						AND T.ReadyToQueue = 1
						AND T.IntendToPartition = 1
						AND T.IsStorageChanging = 1)

--INSERT ROWS FOR TABLES THAT ARE GOING TO BE PARTITIONED NOW
INSERT INTO DDI.RefreshIndexes_PartitionState ( SchemaName ,ParentTableName , PrepTableName, PartitionFromValue ,PartitionToValue ,DataSynchState ,LastUpdateDateTime )
SELECT DISTINCT SchemaName, ParentTableName, UnPartitionedPrepTableName, PartitionFunctionValue, NextPartitionFunctionValue, 0, GETDATE()
FROM DDI.fnDataDrivenIndexes_GetPartitionSQL () FN
WHERE EXISTS (	SELECT 'True' 
				FROM DDI.vwTables T 
				WHERE T.SchemaName = FN.SchemaName
					AND T.TableName = FN.ParentTableName
					AND T.ReadyToQueue = 1
					AND T.IntendToPartition = 1
					AND T.IsStorageChanging = 1)
	AND NOT EXISTS (	SELECT 'True' 
					FROM DDI.RefreshIndexes_PartitionState PS 
					WHERE PS.SchemaName = FN.SchemaName
						AND PS.ParentTableName = FN.ParentTableName
						AND PS.PrepTableName = FN.UnPartitionedPrepTableName)

--IN CASE THE PARTITIONING STRATEGY CHANGES FOR A TABLE, DELETE THE OLD PARTITIONS THAT NO LONGER EXIST.
DELETE PS
FROM DDI.RefreshIndexes_PartitionState PS
WHERE NOT EXISTS(	SELECT 'True' 
					FROM DDI.RefreshIndexes_PartitionState PS2
					WHERE PS.SchemaName = PS2.SchemaName
						AND PS.ParentTableName = PS2.ParentTableName
						AND PS.PrepTableName = PS2.PrepTableName)
GO
