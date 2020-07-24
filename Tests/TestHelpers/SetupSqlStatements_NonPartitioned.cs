using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DOI.TestHelpers;

namespace DOI.Tests.TestHelpers
{
    public static class SetupSqlStatements_NonPartitioned
    {
        public static string setUpDatabasesSql = @"
IF NOT EXISTS(SELECT 'True' FROM sys.databases WHERE name = 'DOIUnitTests')
BEGIN
    CREATE DATABASE [DOIUnitTests]
        CONTAINMENT = PARTIAL
            ON  PRIMARY (   NAME = N'DOIUnitTests', 
                            FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\DOIUnitTests.mdf' , 
                            SIZE = 8192KB , 
                            MAXSIZE = UNLIMITED, 
                            FILEGROWTH = 65536KB )
        LOG ON (    NAME = N'DOIUnitTests_log', 
                    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\DOIUnitTests_log.ldf' , 
                    SIZE = 66560KB , 
                    MAXSIZE = 2048GB , 
                    FILEGROWTH = 65536KB )
END

INSERT INTO DOI.DOI.Databases(DatabaseName)
VALUES(N'DOIUnitTests')";

        public static string setUpPartitionFunctionsSql = SetupSqlStatements_Partitioned.PartitionFunction_Setup;

        public static string tearDownPartitionFunctionSql = @"
DROP PARTITION SCHEME ";

        public static string setUpConstraintsMetadataSql = @"";
        public static string setUpDOISettings = @"";
        public static string setUpTablesMetadata = @"
INSERT INTO [DOI].[Tables] (DatabaseName		, [SchemaName]	,[TableName]	,[PartitionColumn]	,[Storage_Desired]	,[IntendToPartition]	,[ReadyToQueue])
 VALUES ('DOIUnitTests'	, 'dbo'			,'TempA'		, NULL				,'PRIMARY'			,0						,1)
	   ,('DOIUnitTests'	, 'dbo'			,'TempB'		, NULL				,'PRIMARY'			,0						,1))";

        public static string setUpTablesSql = @"
USE DOIUnitTests

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
	TransactionUtcDt datetime2(7) NOT NULL)";


        public static string setUpIndexesMetadataSql = @"
USE DOI

--NIDX_TempA_Report

DELETE DOI.IndexesRowStore WHERE DatabaseName = 'DOIUnitTests' AND IndexName = 'NIDX_TempA_Report'

INSERT INTO DOI.IndexesRowStore 
		(	DatabaseName		, SchemaName	,TableName	,IndexName				,IsUnique_Desired	,IsPrimaryKey_Desired	, IsUniqueConstraint_Desired, IsClustered_Desired	,KeyColumnList_Desired							,IncludedColumnList_Desired	,IsFiltered_Desired ,FilterPredicate_Desired	,[Fillfactor_Desired]	,OptionPadIndex_Desired ,OptionStatisticsNoRecompute_Desired	,OptionStatisticsIncremental_Desired	,OptionIgnoreDupKey_Desired ,OptionResumable_Desired	,OptionMaxDuration_Desired	,OptionAllowRowLocks_Desired	,OptionAllowPageLocks_Desired	,OptionDataCompression_Desired	, Storage_Desired	, PartitionColumn_Desired	)
VALUES	(	'DOIUnitTests'	, N'dbo'		, N'TempA'	, N'NIDX_TempA_Report'	, 0					, 0						, 0					, 0				, N'TransactionUtcDt ASC'				,N'TextCol'			, 0			, NULL				, 80			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, 'NONE'				, 'PRIMARY'		, NULL				)";
        public static string setUpIndexColumnsMetadataSql = @"";
        public static string setUpStatisticsMetadataSql = @"
INSERT INTO DOI.[Statistics] (DatabaseName		, SchemaName, TableName, StatisticsName		, StatisticsColumnList_Desired	, SampleSizePct_Desired	, IsFiltered_Desired, FilterPredicate_Desired	, IsIncremental_Desired	,NoRecompute_Desired,LowerSampleSizeToDesired	, ReadyToQueue)
VALUES						 ('DOIUnitTests', 'dbo'		, 'TempA'  , 'ST_TempA_TempAId' , 'TempAId'						, 0						, 0					, NULL						, 0						,0					,0							, 1)

CREATE STATISTICS ST_TempA_TempAId
    ON dbo.TempA ( TempAId )
    WITH INCREMENTAL = OFF;
";
        public static string setUpIndexPartitionsMetadataSql = @"";
        public static string setUpForeignKeysMetadataSql = @"";
        public static string setUpBusinessHoursScheduleMetadataSql = @"";

        public static string tearDownSql = @"
USE DOI

DELETE DOI.DefaultConstraints			WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.[Statistics]					WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.IndexesColumnStore			WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.IndexesRowStore				WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.ForeignKeys					WHERE DatabaseName = 'DOIUnitTests' AND ReferencedTableName		IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.Tables						WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.Log							WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')


USE DOIUnitTests

DROP TABLE IF EXISTS dbo.TempA
DROP TABLE IF EXISTS dbo.TempB
DROP TABLE IF EXISTS dbo.AAA_SpaceError";
    }
}
