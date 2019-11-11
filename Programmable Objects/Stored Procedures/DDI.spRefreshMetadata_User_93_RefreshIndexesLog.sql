IF OBJECT_ID('[DDI].[spRefreshMetadata_User_93_RefreshIndexesLog]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_93_RefreshIndexesLog];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_93_RefreshIndexesLog]

AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'RefreshIndexesLog',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

EXEC DDI.spBackupTableWithDateName 
	@SchemaName = 'DDI',
	@TableName = 'RefreshIndexesLog'

DROP TABLE IF EXISTS DDI.RefreshIndexesLog

	CREATE TABLE DDI.RefreshIndexesLog (
		RefreshIndexLogID	    INT IDENTITY(1,1)   NOT NULL,
		SchemaName			    NVARCHAR(128)       NOT NULL,
		TableName			    NVARCHAR(128)       NOT NULL,
		IndexName			    NVARCHAR(128)       NOT NULL,
		PartitionNumber		    SMALLINT	        NOT NULL
			CONSTRAINT Def_RefreshIndexesLog_PartitionNumber
				DEFAULT(1),
		IndexSizeInMB		    INT			        NOT NULL,
		LoginName			    NVARCHAR(128)       NOT NULL,
		UserName			    NVARCHAR(128)       NOT NULL,
		LogDateTime			    DATETIME2           NOT NULL
			CONSTRAINT Def_RefreshIndexesLog_LogDateTime
				DEFAULT(SYSDATETIME()),
		SQLStatement		    VARCHAR(MAX)        NULL,
		IndexOperation		    VARCHAR(50)         NOT NULL,
		IsOnlineOperation       BIT                 NOT NULL,
		[RowCount]			    INT                 NOT NULL,
		TableChildOperationId	SMALLINT            NOT NULL,
		RunStatus			    VARCHAR(20)         NOT NULL
			CONSTRAINT Chk_RefreshIndexesLog_RunStatus
				CHECK (RunStatus IN ('Start', 'Running', 'Finish', 'Error', 'Error - Retrying...', 'Error - Skipping...')),
		ErrorText			    VARCHAR(MAX)        NULL,
		TransactionId		    UNIQUEIDENTIFIER    NULL,
		BatchId				    UNIQUEIDENTIFIER    NOT NULL,
		SeqNo				    INT                 NOT NULL,
		ExitTableLoopOnError	BIT                 NOT NULL,
		CONSTRAINT PK_RefreshIndexesLog
			PRIMARY KEY NONCLUSTERED (RefreshIndexLogID),
		CONSTRAINT UQ_RefreshIndexesLog
			UNIQUE NONCLUSTERED (SchemaName, TableName, IndexName, PartitionNumber, IndexOperation, RunStatus, TableChildOperationId, LogDateTime)
			)

WITH (MEMORY_OPTIMIZED = ON)

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL

GO
