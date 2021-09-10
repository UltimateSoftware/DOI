USE DOI

IF NOT EXISTS (SELECT 'True' FROM DOI.Databases WHERE DatabaseName = 'DOIUnitTests')
BEGIN
	INSERT INTO DOI.Databases VALUES('DOIUnitTests')
END

INSERT INTO [DOI].[Tables]
           (DatabaseName		, [SchemaName]	,[TableName]	,[PartitionColumn]	,[Storage_Desired]	,[IntendToPartition]	,[ReadyToQueue]	, [UpdateTimeStampColumn])
VALUES     ('DOIUnitTests'		, 'dbo'			,'TempA'		, NULL				,'PRIMARY'			,0						,1				, 'UpdatedUtcDt')
		  ,('DOIUnitTests'		, 'dbo'			,'TempB'		, NULL				,'PRIMARY'			,0						,1				, 'UpdatedUtcDt')

INSERT INTO DOI.DefaultConstraints	(DatabaseName	,SchemaName	,TableName	,ColumnName		,DefaultDefinition	,DefaultConstraintName)
VALUES								(N'DOIUnitTests',N'dbo'		,N'TempA'	,N'UpdatedUtcDt',N'(sysdatetime())'	,N'Def_TempA_UpdatedUtcDt')

INSERT INTO DOI.DefaultConstraints	(DatabaseName	,SchemaName	,TableName	,ColumnName		,DefaultDefinition	,DefaultConstraintName)
VALUES								(N'DOIUnitTests',N'dbo'		,N'TempB'	,N'UpdatedUtcDt',N'(sysdatetime())'	,N'Def_TempB_UpdatedUtcDt')

INSERT INTO DOI.[Statistics] (DatabaseName		, SchemaName, TableName, StatisticsName		, StatisticsColumnList_Desired	, SampleSizePct_Desired	, IsFiltered_Desired, FilterPredicate_Desired	, IsIncremental_Desired	,NoRecompute_Desired,LowerSampleSizeToDesired	, ReadyToQueue)
VALUES						 ('DOIUnitTests', 'dbo'		, 'TempA'  , 'ST_TempA_TempAId' , 'TempAId'						, 0						, 0					, NULL						, 0						,0					,0							, 1)

INSERT INTO DOI.IndexesRowStore		(DatabaseName, SchemaName	,TableName	,IndexName		,IsUnique_Desired	,IsPrimaryKey_Desired	, IsUniqueConstraint_Desired, IsClustered_Desired	,KeyColumnList_Desired	    ,IncludedColumnList_Desired	,IsFiltered_Desired ,FilterPredicate_Desired	,[Fillfactor_Desired]	    ,OptionPadIndex_Desired ,OptionStatisticsNoRecompute_Desired	,OptionStatisticsIncremental_Desired	,OptionIgnoreDupKey_Desired ,OptionResumable_Desired	,OptionMaxDuration_Desired	,OptionAllowRowLocks_Desired	,OptionAllowPageLocks_Desired	,OptionDataCompression_Desired	, Storage_Desired	, PartitionColumn_Desired	)
VALUES								('DOIUnitTests', N'dbo'		, N'TempA'	, N'PK_TempA'	, 1			        , 1				        , 0					        , 0				        , N'TempAId ASC'            , NULL				        , 0			        , NULL				        , 90				        , 1				        , 0								        , 0								        , 0					        , DEFAULT			        , 0					        , 1						        , 1						        , 'NONE'				        , 'PRIMARY'		    , NULL				)

INSERT INTO DOI.IndexesRowStore		(	DatabaseName	, SchemaName	,TableName	,IndexName		,IsUnique_Desired	,IsPrimaryKey_Desired	, IsUniqueConstraint_Desired, IsClustered_Desired	,KeyColumnList_Desired	    ,IncludedColumnList_Desired	,IsFiltered_Desired ,FilterPredicate_Desired	,[Fillfactor_Desired]	    ,OptionPadIndex_Desired ,OptionStatisticsNoRecompute_Desired	,OptionStatisticsIncremental_Desired	,OptionIgnoreDupKey_Desired ,OptionResumable_Desired	,OptionMaxDuration_Desired	,OptionAllowRowLocks_Desired	,OptionAllowPageLocks_Desired	,OptionDataCompression_Desired	, Storage_Desired	, PartitionColumn_Desired	)
VALUES								(	'DOIUnitTests'	, N'dbo'		, N'TempB'	, N'PK_TempB'	, 1			        , 1				        , 0					        , 0				        , N'TempBId ASC'            , NULL				        , 0			        , NULL				        , 90			            , DEFAULT		        , DEFAULT						        , DEFAULT						        , DEFAULT			        , DEFAULT			        , DEFAULT			        , DEFAULT				        , DEFAULT				        , 'NONE'				        , 'PRIMARY'		    , NULL				)

USE DOIUnitTests


SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

--Create table TempA
CREATE TABLE dbo.TempA(
	TempAId uniqueidentifier NOT NULL,
	TransactionUtcDt datetime2(7) NOT NULL,
	IncludedColumn VARCHAR(100) NULL,
	TextCol VARCHAR(8000) NULL,
	UpdatedUtcDt DATETIME2 NOT NULL
		CONSTRAINT Def_TempA_UpdatedUtcDt
			DEFAULT SYSDATETIME(),

	CONSTRAINT PK_TempA
		PRIMARY KEY NONCLUSTERED (TempAId)
)

--Create table TempB used to test Foreign keys
CREATE TABLE dbo.TempB(
	TempBId uniqueidentifier NOT NULL,
	TempAId uniqueidentifier NOT NULL,
	TransactionUtcDt datetime2(7) NOT NULL,
	UpdatedUtcDt DATETIME2 NOT NULL 
		CONSTRAINT Def_TempB_UpdatedUtcDt
			DEFAULT SYSDATETIME(),

	CONSTRAINT PK_TempB 
		PRIMARY KEY NONCLUSTERED (TempBId) --THIS TABLE HAS A CLUSTERED COLUMNMSTORE INDEX
)

CREATE STATISTICS ST_TempA_TempAId
    ON dbo.TempA ( TempAId )
    WITH INCREMENTAL = OFF;