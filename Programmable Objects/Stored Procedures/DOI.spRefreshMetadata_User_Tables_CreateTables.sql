IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Tables_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Tables_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_Tables_CreateTables]

AS

--exec dbo.spEnableDisableAllFKs 
--    @Action = 'DISABLE', 
--    @ForMetadataTablesOnly = 1

--EXEC DOI.spForeignKeysDrop
--    @ForMetadataTablesOnly = 1,
--	@ReferencedSchemaName	= 'DOI',
--	@ReferencedTableName	= 'Tables'

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'Tables',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL


EXEC [DOI].[spRefreshMetadata_User_Tables_DropRefFKs]



DROP TABLE IF EXISTS DOI.Tables


	CREATE TABLE DOI.Tables(
        DatabaseName                        NVARCHAR(128) NOT NULL,
		SchemaName						    NVARCHAR(128) NOT NULL,
		TableName						    NVARCHAR(128) NOT NULL,
		PartitionColumn					    NVARCHAR(128) NULL, --VALIDATE THAT THIS COLUMN EXISTS IN DB.
		Storage_Desired					    NVARCHAR(128) NULL, --VALIDATE THAT THIS NAME IS A VALID STORAGE CONTAINER.
        Storage_Actual                      NVARCHAR(128) NULL,
        StorageUnderlyingFilegroup_Desired  NVARCHAR(128) NULL,
        StorageUnderlyingFilegroup_Actual   NVARCHAR(128) NULL,
        StorageType_Desired                 NVARCHAR(128) NULL,
        StorageType_Actual                  NVARCHAR(128) NULL,

		--UseBCPStrategy					BIT NOT NULL /*I THINK WE CAN DROP THIS COLUMN.  IF STORAGE CHANGES WE HAVE TO USE BCP EVERY TIME.
		--												MAYBE WE SHOULD ADD AN UPDATETYPE OF 'BCP' AND ENABLE IT WHENEVER
		--												STORAGE CHANGES.  */
		--	CONSTRAINT Def_Tables_UseBCPStrategy
		--		DEFAULT 0,
		IntendToPartition				    BIT NOT NULL /*DO WE NEED THIS COLUMN?  I THINK THAT PUTTING A PARTITION SCHEME NAME IN THE
													'NewStorage' COLUMN SAYS THAT YOU 'INTEND TO PARTITION'.  DON'T KNOW ABOUT THIS
													BECAUSE WE USE THIS COLUMN IN LOTS OF VALIDATIONS.*/
			CONSTRAINT Def_Tables_IntendToPartition
				DEFAULT 0,
		--EnableRunPartitioning			    BIT NOT NULL--I THINK WE CAN DROP THIS COLUMN. READYTOQUEUE NOW DOES THIS FUNCTION.
		--	CONSTRAINT Def_Tables_EnableRunPartitioning
		--		DEFAULT 0,
		ReadyToQueue					    BIT NOT NULL
			CONSTRAINT Def_Tables_ReadyToQueue
				DEFAULT 0,
        AreIndexesFragmented                BIT NOT NULL
   			CONSTRAINT Def_Tables_AreIndexesFragmented
				DEFAULT 0,
		AreIndexesBeingUpdated              BIT NOT NULL
			CONSTRAINT Def_Tables_AreIndexesBeingUpdated
				DEFAULT 0,
		AreIndexesMissing                   BIT NOT NULL
			CONSTRAINT Def_Tables_AreIndexesMissing
				DEFAULT 0,
		IsClusteredIndexBeingDropped        BIT NOT NULL
			CONSTRAINT Def_Tables_IsClusteredIndexBeingDropped
				DEFAULT 0,
		WhichUniqueConstraintIsBeingDropped VARCHAR(10) NOT NULL
			CONSTRAINT Def_Tables_WhichUniqueConstraintIsBeingDropped
				DEFAULT 'None',
		IsStorageChanging                   BIT NOT NULL
			CONSTRAINT Def_Tables_IsStorageChanging
				DEFAULT 0,
		NeedsTransaction                    BIT NOT NULL
			CONSTRAINT Def_Tables_NeedsTransaction
				DEFAULT 0,
        AreStatisticsChanging               BIT NOT NULL
			CONSTRAINT Def_Tables_AreStatisticsChanging
				DEFAULT 0,
		DSTriggerSQL                        VARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		PKColumnList                        VARCHAR(MAX) NULL,
        PKColumnListJoinClause              VARCHAR(MAX) NULL,
    	ColumnListNoTypes                   VARCHAR(MAX) NULL,
	    ColumnListWithTypes                 VARCHAR(MAX) NULL,
    	UpdateColumnList                    VARCHAR(MAX) NULL,
        NewPartitionedPrepTableName         NVARCHAR(128) NULL,
        PartitionFunctionName               NVARCHAR(128) NULL

		CONSTRAINT PK_Tables
			PRIMARY KEY NONCLUSTERED(DatabaseName, SchemaName, TableName),
		CONSTRAINT Chk_Tables_PartitioningSetup
			CHECK ((IntendToPartition = 1 AND PartitionColumn IS NOT NULL)
					OR (IntendToPartition = 0 AND PartitionColumn IS NULL)),
        CONSTRAINT FK_Tables_Databases
            FOREIGN KEY (DatabaseName)
                REFERENCES DOI.Databases(DatabaseName)) 

    WITH (MEMORY_OPTIMIZED = ON)

EXEC DOI.spRefreshMetadata_User_Tables_InsertData
EXEC DOI.spRefreshMetadata_User_Tables_UpdateData
EXEC DOI.spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData


EXEC [DOI].[spRefreshMetadata_User_Tables_AddRefFKs]

EXEC DOI.sp_ExecuteSQLByBatch @RecreateSQL


GO
