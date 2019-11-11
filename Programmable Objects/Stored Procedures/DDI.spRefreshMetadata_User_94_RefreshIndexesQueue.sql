IF OBJECT_ID('[DDI].[spRefreshMetadata_User_94_RefreshIndexesQueue]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_94_RefreshIndexesQueue];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_94_RefreshIndexesQueue]

AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'RefreshIndexesQueue',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DDI.RefreshIndexesQueue

CREATE TABLE DDI.RefreshIndexesQueue (
		SchemaName			NVARCHAR(128) NOT NULL,
		TableName			NVARCHAR(128) NOT NULL,
		IndexName			NVARCHAR(128) NOT NULL,
		PartitionNumber		SMALLINT	  NOT NULL
			CONSTRAINT Def_RefreshIndexesQueue_PartitionNumber
				DEFAULT 1,
		IndexSizeInMB		INT			  NOT NULL,
		ParentSchemaName	NVARCHAR(128) NULL,
		ParentTableName 	NVARCHAR(128) NULL,
		ParentIndexName 	NVARCHAR(128) NULL,
		IndexOperation		VARCHAR(50) NOT NULL,
			CONSTRAINT Chk_RefreshIndexesQueue_IndexOperation
				CHECK (IndexOperation IN (	'Drop Index', 'Create Index', 'Create Constraint', 'Alter Index', 'Prep Table SQL', 
											'Create Data Synch Trigger', 'Create Final Data Synch Table', 'Create Final Data Synch Trigger', 
											'Loading Data', 'Recreate All FKs', 'Drop Ref FKs', 'Partition Prep Table SQL', 
											'Switch Partitions SQL', 'Begin Tran', 'Commit Tran', 'Check Constraint SQL', 'Drop Table SQL', 
											'Rename New Partitioned Prep Table', 'Rename Existing Table', 'Rename New Partitioned Prep Table Index', 
											'Rename New Partitioned Prep Table Constraint', 'Rename Existing Table Index', 'Rename Existing Table Constraint', 
											'Synch Deletes', 'Synch Inserts', 'Synch Updates', 'Rollback DDL',
											'Enable CmdShell', 'Disable CmdShell', 'Add back Ref Table FKs', 'Add back Parent Table FKs', 'Drop Ref Old Table FKs', 
											'Drop Parent Old Table FKs', 'Temp Table SQL', 'FinalValidation', 'Update to In-Progress', 'Delete from Queue', 
											'Rename Data Synch Table', 'Drop Data Synch Trigger', 'Drop Data Synch Table', 
											'Partition Data Validation SQL', 'Prior Error Validation SQL', 'Index Revert Rename', 
											'Constraint Revert Rename',	'Table Revert Rename', 'Stop Processing', 'Free Data Space Validation', 'Free Log Space Validation',
                                            'Free TempDB Space Validation', 'Data Synch Trigger Revert Rename',	'Clear Queue of Other Tables', 'Turn On DataSynch', 
                                            'Turn Off DataSynch', 'Clean Up Tables', 'Kill', 'Get Application Lock', 'Release Application Lock', 'Resource Governor Settings', 
                                            'Partition State Metadata Validation', 'Delete PartitionState Metadata', 'Drop Statistics', 'Create Statistics', 'Update Statistics',
                                            'Delay')),
		IsOnlineOperation	BIT NOT NULL,
		TableChildOperationId		SMALLINT NOT NULL
			CONSTRAINT Def_RefreshIndexesQueue_TableChildOperationId
				DEFAULT 0,
		SQLStatement		VARCHAR(MAX) NOT NULL,
		SeqNo				INT NOT NULL,
		DateTimeInserted	DATETIME2 NOT NULL
			CONSTRAINT Def_RefreshIndexesQueue_DateTimeInserted
				DEFAULT SYSDATETIME(),
		InProgress			BIT NOT NULL
			CONSTRAINT Def_RefreshIndexesQueue_InProgress
				DEFAULT 0,
		RunStatus			VARCHAR(7) NOT NULL
			CONSTRAINT Chk_RefreshIndexesQueue_RunStatus
				CHECK (RunStatus IN ('Start', 'Running', 'Finish'))
			CONSTRAINT Def_RefreshIndexesQueue_RunStatus
				DEFAULT ('Running'), --DO WE NEED THIS?
		ErrorMessage		VARCHAR(MAX) NULL,
		TransactionId		UNIQUEIDENTIFIER NULL,
		BatchId				UNIQUEIDENTIFIER NOT NULL,
		ExitTableLoopOnError	BIT NOT NULL
			CONSTRAINT Def_RefreshIndexStructureQueue
				DEFAULT 0,
		CONSTRAINT PK_RefreshIndexesQueue
			PRIMARY KEY NONCLUSTERED (SchemaName, TableName, IndexName, PartitionNumber, IndexOperation, TableChildOperationId)--,
)

WITH (MEMORY_OPTIMIZED = ON)

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL

GO
