SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

--Create table TempA
CREATE TABLE dbo.TempA(
	TempAId uniqueidentifier NOT NULL,
	TransactionUtcDt datetime2(7) NOT NULL,
	IncludedColumn VARCHAR(50) NULL,
	TextCol VARCHAR(8000) NULL 
)

--Create table TempB used to test Foreign keys
CREATE TABLE dbo.TempB(
	TempBId uniqueidentifier NOT NULL,
	TempAId uniqueidentifier NOT NULL,
	TransactionUtcDt datetime2(7) NOT NULL,
)

INSERT INTO [Utility].[Tables]
           ([SchemaName]	,[TableName]	,[PartitionColumn]	,[NewStorage]	,[UseBCPStrategy]	,[IntendToPartition]	,[EnableRunPartitioning]	,[ReadyToQueue])
     VALUES
           ('dbo'			,'TempA'			, NULL				,'PRIMARY'		,0					,0						,0							,1)
		  ,('dbo'			,'TempB'			, NULL				,'PRIMARY'		,0					,0						,0							,1)

INSERT INTO Utility.[Statistics] (SchemaName, TableName, StatisticsName		, StatisticsColumnList	, SampleSizePct	, IsFiltered, FilterPredicate	, IsIncremental	,NoRecompute,LowerSampleSizeToDesired, ReadyToQueue)
VALUES							 ('dbo'		, 'TempA'  , 'ST_TempA_TempAId' , 'TempAId'				, 0				, 0			, NULL				, 0				,0			,0			, 1)

CREATE STATISTICS ST_TempA_TempAId
    ON dbo.TempA ( TempAId )
    WITH INCREMENTAL = OFF;