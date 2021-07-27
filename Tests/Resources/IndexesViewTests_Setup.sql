USE DOI

IF NOT EXISTS (SELECT 'True' FROM DOI.Databases WHERE DatabaseName = 'DOIUnitTests')
BEGIN
	INSERT INTO DOI.Databases VALUES('DOIUnitTests')
END

INSERT INTO [DOI].[Tables]
           (DatabaseName		, [SchemaName]	,[TableName]	,[PartitionColumn]	,[Storage_Desired]	,[IntendToPartition]	,[ReadyToQueue])
     VALUES
           ('DOIUnitTests'	, 'dbo'			,'TempA'		, NULL				,'PRIMARY'			,0						,1)
		  ,('DOIUnitTests'	, 'dbo'			,'TempB'		, NULL				,'PRIMARY'			,0						,1)

INSERT INTO DOI.[Statistics] (DatabaseName		, SchemaName, TableName, StatisticsName		, StatisticsColumnList_Desired	, SampleSizePct_Desired	, IsFiltered_Desired, FilterPredicate_Desired	, IsIncremental_Desired	,NoRecompute_Desired,LowerSampleSizeToDesired	, ReadyToQueue)
VALUES						 ('DOIUnitTests', 'dbo'		, 'TempA'  , 'ST_TempA_TempAId' , 'TempAId'						, 0						, 0					, NULL						, 0						,0					,0							, 1)


USE DOIUnitTests


SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

--Create table TempA
CREATE TABLE dbo.TempA(
	TempAId uniqueidentifier NOT NULL,
	TransactionUtcDt datetime2(7) NOT NULL,
	IncludedColumn VARCHAR(100) NULL,
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