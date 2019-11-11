IF OBJECT_ID('[DDI].[spRefreshMetadata_User_PartitionFunctions_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_PartitionFunctions_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_PartitionFunctions_CreateTables]

AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DDI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DDI',
    @TableName = 'PartitionFunctions',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DDI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS DDI.PartitionFunctions


CREATE TABLE DDI.PartitionFunctions(
    DatabaseName SYSNAME,
	PartitionFunctionName SYSNAME,
	PartitionFunctionDataType SYSNAME,
	BoundaryInterval VARCHAR(10) NOT NULL
		CONSTRAINT Chk_PartitionFunctions_BoundaryInterval
			CHECK (BoundaryInterval IN ('Yearly', 'Monthly')),
	NumOfFutureIntervals TINYINT NOT NULL,
	InitialDate DATE NOT NULL,
	UsesSlidingWindow BIT NOT NULL,
	SlidingWindowSize SMALLINT NULL,
	IsDeprecated BIT NOT NULL,
	PartitionSchemeName NVARCHAR(128) NULL,--AS ,
	NumOfCharsInSuffix TINYINT NULL,/*AS	,*/
	LastBoundaryDate DATE NULL, /*AS ,*/
	NumOfTotalPartitionFunctionIntervals SMALLINT NULL, /*AS */
	NumOfTotalPartitionSchemeIntervals SMALLINT NULL,
	MinValueOfDataType VARCHAR(20) NULL
	CONSTRAINT PK_PartitionFunctions
		PRIMARY KEY NONCLUSTERED (DatabaseName, PartitionFunctionName),
	CONSTRAINT Chk_PartitionFunctions_SlidingWindow
		CHECK ((UsesSlidingWindow = 1 AND SlidingWindowSize IS NOT NULL)
				OR (UsesSlidingWindow = 0 AND SlidingWindowSize IS NULL)))
    WITH (MEMORY_OPTIMIZED = ON)

EXEC DDI.sp_ExecuteSQLByBatch @RecreateSQL
GO
