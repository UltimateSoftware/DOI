USE DDI


INSERT INTO [DDI].[Tables]
           (DatabaseName		, [SchemaName]	,[TableName]	,[PartitionColumn]	,[Storage_Desired]	,[IntendToPartition]	,[ReadyToQueue])
     VALUES
           ('PaymentReporting'	, 'dbo'			,'TempA'		, NULL				,'PRIMARY'			,0						,1)
		  ,('PaymentReporting'	, 'dbo'			,'TempB'		, NULL				,'PRIMARY'			,0						,1)

INSERT INTO DDI.[Statistics] (DatabaseName		, SchemaName, TableName, StatisticsName		, StatisticsColumnList_Desired	, SampleSizePct_Desired	, IsFiltered_Desired, FilterPredicate_Desired	, IsIncremental_Desired	,NoRecompute_Desired,LowerSampleSizeToDesired	, ReadyToQueue)
VALUES						 ('PaymentReporting', 'dbo'		, 'TempA'  , 'ST_TempA_TempAId' , 'TempAId'						, 0						, 0					, NULL						, 0						,0					,0							, 1)


USE PaymentReporting


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

CREATE STATISTICS ST_TempA_TempAId
    ON dbo.TempA ( TempAId )
    WITH INCREMENTAL = OFF;