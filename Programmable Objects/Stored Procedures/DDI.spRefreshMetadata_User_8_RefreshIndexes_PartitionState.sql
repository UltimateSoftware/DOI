IF OBJECT_ID('[DDI].[spRefreshMetadata_User_8_RefreshIndexes_PartitionState]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_8_RefreshIndexes_PartitionState];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_8_RefreshIndexes_PartitionState]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'RefreshIndexes_PartitionState',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DDI.RefreshIndexes_PartitionState


	CREATE TABLE DDI.RefreshIndexes_PartitionState (
        DatabaseName SYSNAME,
		SchemaName SYSNAME ,
		ParentTableName SYSNAME ,
		PrepTableName SYSNAME ,
		PartitionFromValue DATE NOT NULL,
		PartitionToValue DATE NOT NULL,
		DataSynchState BIT NOT NULL,
		LastUpdateDateTime DATETIME 
			CONSTRAINT Def_RefreshIndexes_PartitionState_LastUpdateDateTime
				DEFAULT (GETDATE())

		CONSTRAINT PK_RefreshIndexes_PartitionState 
			PRIMARY KEY NONCLUSTERED(DatabaseName, SchemaName, ParentTableName, PrepTableName, PartitionFromValue))
        WITH (MEMORY_OPTIMIZED = ON)

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL

GO
