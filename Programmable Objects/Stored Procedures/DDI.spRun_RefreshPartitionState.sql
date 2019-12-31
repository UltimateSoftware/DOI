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
FROM DDI.Run_PartitionState PS
WHERE NOT EXISTS(	SELECT 'True'
					FROM DDI.vwTables T
					WHERE T.DatabaseName = PS.DatabaseName 
                        AND T.SchemaName = PS.SchemaName
						AND T.TableName = PS.ParentTableName
						AND T.ReadyToQueue = 1
						AND T.IntendToPartition = 1
						AND T.IsStorageChanging = 1)

--INSERT ROWS FOR TABLES THAT ARE GOING TO BE PARTITIONED NOW
INSERT INTO DDI.Run_PartitionState ( DatabaseName, SchemaName ,ParentTableName , PrepTableName, PartitionFromValue ,PartitionToValue ,DataSynchState ,LastUpdateDateTime )
SELECT DISTINCT DatabaseName, SchemaName, TableName, PrepTableName, PT.BoundaryValue, PT.NextBoundaryValue, 0, GETDATE()
FROM DDI.vwTables_PrepTables PT
WHERE EXISTS (	SELECT 'True' 
				FROM DDI.vwTables T 
				WHERE T.DatabaseName = PT.DatabaseName 
                    AND T.SchemaName = PT.SchemaName
					AND T.TableName = PT.TableName
					AND T.ReadyToQueue = 1
					AND T.IntendToPartition = 1
					AND T.IsStorageChanging = 1)
	AND NOT EXISTS (SELECT 'True' 
					FROM DDI.Run_PartitionState PS 
					WHERE PS.DatabaseName = PT.DatabaseName 
                        AND PS.SchemaName = PT.SchemaName
						AND PS.ParentTableName = PT.TableName
						AND PS.PrepTableName = PT.PrepTableName)

--IN CASE THE PARTITIONING STRATEGY CHANGES FOR A TABLE, DELETE THE OLD PARTITIONS THAT NO LONGER EXIST.
DELETE PS
FROM DDI.Run_PartitionState PS
WHERE NOT EXISTS(	SELECT 'True' 
					FROM DDI.Run_PartitionState PS2
					WHERE PS.DatabaseName = PS2.DatabaseName 
                        AND PS.SchemaName = PS2.SchemaName
						AND PS.ParentTableName = PS2.ParentTableName
						AND PS.PrepTableName = PS2.PrepTableName)
GO
