using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Simple.Data.Ado.Schema;


namespace DOI.Tests.TestHelpers
{
    public static class SetupSqlStatements_NonPartitioned
    {
        private const string DatabaseName = "DOIUnitTests";

        private const string NonPartitionedTableName = "TempA";

        public static string setUpTablesMetadata = $@"
INSERT INTO [DOI].[Tables] ([DatabaseName]		, [SchemaName]	,[TableName]	,[PartitionColumn]	,[Storage_Desired]	,[IntendToPartition]	,[ReadyToQueue], [UpdateTimeStampColumn])
 VALUES ('DOIUnitTests'	, 'dbo'			,'{NonPartitionedTableName}'		, NULL				,'PRIMARY'			,0						,1, 'UpdateTimeStamp')
	   ,('DOIUnitTests'	, 'dbo'			,'TempB'		, NULL				,'PRIMARY'			,0						,1, 'UpdateTimeStamp')";

        public static string setUpIndexesMetadataSql = $@"            
    INSERT INTO DOI.IndexesRowStore (DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, IsFiltered_Desired, FilterPredicate_Desired,Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, PartitionFunction_Desired, PartitionColumn_Desired, Storage_Desired)
                      
    Select 
        DatabaseName                            = N'{DatabaseName}'
        ,SchemaName					            = N'dbo'
        ,TableName                              = N'{NonPartitionedTableName}'
        ,IndexName                              = N'CDX_{NonPartitionedTableName}'
        ,IsUnique_Desired                       = 0
        ,IsPrimaryKey_Desired                   = 0
        ,IsUniqueConstraint_Desired             = 0
        ,IsClustered_Desired                    = 1
        ,KeyColumnList_Desired                  = N'TransactionUtcDt ASC'
        ,IncludedColumnList_Desired             = NULL
        ,IsFiltered_Desired                     = 0
        ,FilterPredicate_Desired                = NULL
        ,Fillfactor_Desired                     = 80
        ,OptionPadIndex_Desired                 = 1
        ,OptionStatisticsNoRecompute_Desired    = 0
        ,OptionStatisticsIncremental_Desired    = 0
        ,OptionIgnoreDupKey_Desired             = 0
        ,OptionResumable_Desired                = 0
        ,OptionMaxDuration_Desired              = 0
        ,OptionAllowRowLocks_Desired            = 1
        ,OptionAllowPageLocks_Desired           = 1
        ,OptionDataCompression_Desired          = 'PAGE'
        ,PartitionFunction_Desired              = NULL
        ,PartitionColumn_Desired                = NULL
        ,Storage_Desired                        = '[PRIMARY]'
                     
    UNION  ALL 
                       
	Select  
        DatabaseName                            = N'{DatabaseName}'
        ,SchemaName					            = N'dbo'
        ,TableName                              = N'{NonPartitionedTableName}'
        ,IndexName                              = N'PK_{NonPartitionedTableName}'
        ,IsUnique_Desired                       = 1
        ,IsPrimaryKey_Desired                   = 1
        ,IsUniqueConstraint_Desired             = 0
        ,IsClustered_Desired                    = 0
        ,KeyColumnList_Desired                  = N'TempAId ASC,TransactionUtcDt ASC'
        ,IncludedColumnList_Desired             = NULL
        ,IsFiltered_Desired                     = 0
        ,FilterPredicate_Desired                = NULL
        ,Fillfactor_Desired                     = 80
        ,OptionPadIndex_Desired                 = 1
        ,OptionStatisticsNoRecompute_Desired    = 0
        ,OptionStatisticsIncremental_Desired    = 0
        ,OptionIgnoreDupKey_Desired             = 0
        ,OptionResumable_Desired                = 0
        ,OptionMaxDuration_Desired              = 0
        ,OptionAllowRowLocks_Desired            = 1
        ,OptionAllowPageLocks_Desired           = 1
        ,OptionDataCompression_Desired          = 'PAGE'
        ,PartitionFunction_Desired              = NULL
        ,PartitionColumn_Desired                = NULL
        ,Storage_Desired                        = '[PRIMARY]'
    
	UNION ALL
				 
	Select  
        DatabaseName                            = N'{DatabaseName}'
        ,SchemaName					            = N'dbo'
        ,TableName                              = N'{NonPartitionedTableName}'
        ,IndexName                              = N'IDX_{NonPartitionedTableName}_Comments'
        ,IsUnique_Desired                       = 0
        ,IsPrimaryKey_Desired                   = 0
        ,IsUniqueConstraint_Desired             = 0
        ,IsClustered_Desired                    = 0
        ,KeyColumnList_Desired                  = N'IncludedColumn ASC,TransactionUtcDt ASC'
        ,IncludedColumnList_Desired             = NULL
        ,IsFiltered_Desired                     = 0
        ,FilterPredicate_Desired                = NULL
        ,[Fillfactor_Desired]                   = 80
        ,OptionPadIndex_Desired                 = 1
        ,OptionStatisticsNoRecompute_Desired    = 0
        ,OptionStatisticsIncremental_Desired    = 0
        ,OptionIgnoreDupKey_Desired             = 0
        ,OptionResumable_Desired                = 0
        ,OptionMaxDuration_Desired              = 0
        ,OptionAllowRowLocks_Desired            = 1
        ,OptionAllowPageLocks_Desired           = 1
        ,OptionDataCompression_Desired          = 'PAGE'
        ,PartitionFunction_Desired              = NULL
        ,PartitionColumn_Desired                = NULL
        ,Storage_Desired                        = '[PRIMARY]'

    INSERT INTO DOI.IndexesColumnStore ( DatabaseName, SchemaName ,TableName ,IndexName ,IsClustered_Desired,ColumnList_Desired,IsFiltered_Desired,FilterPredicate_Desired,OptionDataCompression_Desired,OptionDataCompressionDelay_Desired,PartitionFunction_Desired,PartitionColumn_Desired, Storage_Desired )
    SELECT 
          [DatabaseName]                = N'{DatabaseName}'
        , [SchemaName]                  = N'dbo'
        , [TableName]                   = N'{NonPartitionedTableName}'	
        , [IndexName]                   = N'NCCI_{NonPartitionedTableName}_Comments'	
        , [IsClustered]                 = 0
        , [ColumnList]                  = N'IncludedColumn,TransactionUtcDt'				
        , [IsFiltered]                  = 0
        , [FilterPredicate]             = NULL
        , [OptionDataCompression]       = N'COLUMNSTORE'
        , [OptionDataCompressionDelay]  = 0
        ,PartitionFunction_Desired      = NULL
        ,PartitionColumn_Desired        = NULL
        ,Storage_Desired                = '[PRIMARY]'";

        public static string setUpStatisticsMetadataSql = $@"
                                INSERT INTO DOI.[Statistics] ( DatabaseName, SchemaName, TableName, StatisticsName, StatisticsColumnList_Desired, SampleSizePct_Desired, IsFiltered_Desired, FilterPredicate_Desired, IsIncremental_Desired, NoRecompute_Desired, LowerSampleSizeToDesired, ReadyToQueue)
                                VALUES   ( N'{DatabaseName}', N'dbo', N'{NonPartitionedTableName}', 'ST_{NonPartitionedTableName}_TempAId', 'TempAId', 20, 0, NULL, 0, 0, 0, 1)
                                        ,( N'{DatabaseName}', N'dbo', N'{NonPartitionedTableName}', 'ST_{NonPartitionedTableName}_TransactionUtcDt', 'TransactionUtcDt', 20, 0, NULL, 0, 0, 0, 1)
                                        ,( N'{DatabaseName}', N'dbo', N'{NonPartitionedTableName}', 'ST_{NonPartitionedTableName}_IncludedColumn', 'IncludedColumn', 20, 0, NULL, 0, 0, 0, 1)
                                        ,( N'{DatabaseName}', N'dbo', N'{NonPartitionedTableName}', 'ST_{NonPartitionedTableName}_TextCol', 'TextCol', 20, 0, NULL, 0, 0, 0, 1)";

        public static string setUpConstraintsMetadataSql = $@"
                                INSERT INTO DOI.CheckConstraints ( DatabaseName, SchemaName ,TableName ,ColumnName ,CheckDefinition ,IsDisabled ,CheckConstraintName )
                                VALUES ( N'{DatabaseName}', N'dbo', N'{NonPartitionedTableName}', N'TransactionUtcDt', N'(TransactionUtcDt > ''0001-01-01'')', 0, N'Chk_{NonPartitionedTableName}_TransactionUtcDt')

                                INSERT INTO DOI.DefaultConstraints ( DatabaseName, SchemaName ,TableName ,ColumnName ,DefaultDefinition )
                                VALUES ( N'{DatabaseName}', N'dbo', N'{NonPartitionedTableName}', N'TransactionUtcDt', N'(SYSDATETIME())')";

        public static string setUpDOISettings = @"";

        public static string setUpTablesSql = $@"
USE DOIUnitTests

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--Create table {NonPartitionedTableName}
CREATE TABLE dbo.{NonPartitionedTableName}(
	TempAId uniqueidentifier NOT NULL,
	TransactionUtcDt datetime2(7) NOT NULL,
	IncludedColumn VARCHAR(50) NULL,
	TextCol VARCHAR(8000) NULL,
    UpdateTimeStamp DATETIME2 NOT NULL
)

--Create table TempB used to test Foreign keys
CREATE TABLE dbo.TempB(
	TempBId uniqueidentifier NOT NULL,
	TempAId uniqueidentifier NOT NULL,
	TransactionUtcDt datetime2(7) NOT NULL,
    UpdateTimeStamp DATETIME2 NOT NULL)";

        public static string setUpConstraintsSql = $@"
ALTER TABLE dbo.{NonPartitionedTableName} ADD CONSTRAINT Def_{NonPartitionedTableName}_TransactionUtcDt DEFAULT (SYSDATETIME()) FOR TransactionUtcDt;
ALTER TABLE dbo.{NonPartitionedTableName} ADD CONSTRAINT Chk_{NonPartitionedTableName}_TransactionUtcDt CHECK (TransactionUtcDt > '0001-01-01')";

        public static string setUpIndexesSql = $@"
CREATE CLUSTERED INDEX CDX_{NonPartitionedTableName}
ON [dbo].[{NonPartitionedTableName}] (TransactionUtcDt ASC)
WITH (PAD_INDEX = ON, FILLFACTOR = 80, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF,
      STATISTICS_INCREMENTAL = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON,
      MAXDOP = 0, DATA_COMPRESSION = PAGE
     )
ON [PRIMARY];
CREATE NONCLUSTERED INDEX IDX_{NonPartitionedTableName}_Comments
ON [dbo].[{NonPartitionedTableName}] (
                     IncludedColumn ASC,
                     TransactionUtcDt ASC
                 )
WITH (PAD_INDEX = ON, FILLFACTOR = 80, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF,
      STATISTICS_INCREMENTAL = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON,
      MAXDOP = 0, DATA_COMPRESSION = PAGE
     )
ON [PRIMARY];
ALTER TABLE [dbo].[{NonPartitionedTableName}]
ADD CONSTRAINT PK_{NonPartitionedTableName}
    PRIMARY KEY NONCLUSTERED (
                                 TempAId ASC,
                                 TransactionUtcDt ASC
                             )
    WITH (PAD_INDEX = ON, FILLFACTOR = 80, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF,
          STATISTICS_INCREMENTAL = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, DATA_COMPRESSION = PAGE
         ) ON [PRIMARY];
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_{NonPartitionedTableName}_Comments
ON [dbo].[{NonPartitionedTableName}] (
                     IncludedColumn,
                     TransactionUtcDt
                 )
WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, MAXDOP = 0, DATA_COMPRESSION = COLUMNSTORE)
ON [PRIMARY];";

        public static string setUpStatisticsSql = $@"
CREATE STATISTICS ST_{NonPartitionedTableName}_TextCol
ON DOIUnitTests.dbo.{NonPartitionedTableName}
(
    TextCol
)
WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.          , MAXDOP = 0*/,
     INCREMENTAL = OFF;
CREATE STATISTICS ST_{NonPartitionedTableName}_TempAId
ON DOIUnitTests.dbo.{NonPartitionedTableName}
(
    TempAId
)
WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.          , MAXDOP = 0*/,
     INCREMENTAL = OFF;
CREATE STATISTICS ST_{NonPartitionedTableName}_IncludedColumn
ON DOIUnitTests.dbo.{NonPartitionedTableName}
(
    IncludedColumn
)
WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.          , MAXDOP = 0*/,
     INCREMENTAL = OFF;
CREATE STATISTICS ST_{NonPartitionedTableName}_TransactionUtcDt
ON DOIUnitTests.dbo.{NonPartitionedTableName}
(
    TransactionUtcDt
)
WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.          , MAXDOP = 0*/,
     INCREMENTAL = OFF;";

        public static string DataInsert => GenerateDataInsertScript();

        private static string GenerateDataInsertScript()
        {
            StringBuilder insert = new StringBuilder();
            int year = 2014;
            int counter = 0;

            while (++year <= 2022)
            {
                int month = 0;
                while (++month <= 12)
                {
                    counter++;
                    insert.AppendLine($"UNION ALL SELECT '{Guid.NewGuid()}'	,'{year}-{month}-15 {DateTime.Now.TimeOfDay}'	,'Record {counter}'		,'{DateTime.Now.AddDays(counter)}' ,'{DateTime.Now.AddDays(counter)}'");
                }
            }
            return $"INSERT INTO [dbo].[{NonPartitionedTableName}]([TempAId],[TextCol],[IncludedColumn],[TransactionUtcDt],[UpdateTimeStamp])"
                   + Environment.NewLine
                   + insert.ToString().Substring(9);
        }

        public static string DataInNonPartitionedTable = $@" USE {DatabaseName} Select * from dbo.{NonPartitionedTableName}";


        public static string DataMismatchValidation = $@"USE {DatabaseName}
                        IF EXISTS(
	                           Select * FROM [dbo].[{NonPartitionedTableName}]
	                           EXCEPT
	                           Select * FROM [dbo].[{NonPartitionedTableName}_Old]
	                           )
                        OR EXISTS(
                            Select * FROM [dbo].[{NonPartitionedTableName}_Old]
                            EXCEPT
                            Select * FROM [dbo].[{NonPartitionedTableName}]
                            )
                        BEGIN
                            Select ValidationStatus = 'Error: data mismatch between the new and the old table.'
                        END ";

        public static string CheckLiveTable => GenerateTableExistenceCheckScript(NonPartitionedTableName, "dbo");

        public static string CheckOldTable => GenerateTableExistenceCheckScript($"{NonPartitionedTableName}_Old", "dbo");

        public static string CheckOfflineNonPartitionedTable => GenerateTableExistenceCheckScript($"{NonPartitionedTableName}_NewTable", "dbo");

        private static string GenerateTableExistenceCheckScript(string tablename, string schemaname)
        {
            return $@"USE {DatabaseName}
                        SELECT 1
                        FROM sys.tables t 
                        JOIN sys.schemas s on s.schema_id = t.schema_id
                        WHERE 1=1 
                        AND	t.name = '{tablename}' 
                        AND	s.name = '{schemaname}' ";
        }


        public static string CreateTrigger = $@"  CREATE TRIGGER dbo.tr{NonPartitionedTableName}_ins  
                                                    ON dbo.{NonPartitionedTableName} AFTER insert 
                                                    AS 

                                                    SET NOCOUNT ON
                                                                                                        
                                                    DECLARE @SysDate DATETIME2 = SYSDATETIME()";

        public static string setUpForeignKeysMetadataSql = @"";

        public static string IndexesAfterTableExchangeNonPartitioningNewTable = $@"USE {DatabaseName}
                                                        SELECT IndexName = ix.Name
                                                        FROM sys.indexes ix 
                                                            JOIN sys.tables t  on ix.object_id = t.object_id
                                                            JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                        WHERE 1=1
                                                            AND t.name = '{NonPartitionedTableName}'
                                                            AND s.name = 'dbo'";

        public static string IndexesAfterTableExchangeNonPartitioningOldTable = $@"USE {DatabaseName}
                                                        SELECT IndexName = ix.Name
                                                        FROM sys.indexes ix 
                                                            JOIN sys.tables t  on ix.object_id = t.object_id
                                                            JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                        WHERE 1=1
                                                            AND t.name = '{NonPartitionedTableName}_OLD'
                                                            AND s.name = 'dbo'";

        public static string IndexesAfterRevertTableExchangeNonPartitioningTable = $@"USE {DatabaseName}
                                                        SELECT IndexName = ix.Name
                                                        FROM sys.indexes ix 
                                                            JOIN sys.tables t  on ix.object_id = t.object_id
                                                            JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                        WHERE 1=1
                                                            AND t.name = '{NonPartitionedTableName}_NewTable'
                                                            AND s.name = 'dbo'";

        public static string ConstraintsAfterTableExchangeNonPartitioningNewTable = $@"USE {DatabaseName}
                                                            SELECT ConstraintName = x.Name
                                                            FROM (  SELECT parent_object_id, name
                                                                    FROM sys.check_constraints c
                                                                    UNION ALL
                                                                    SELECT parent_object_id, name
                                                                    FROM sys.default_constraints d) x
                                                                INNER JOIN sys.tables t  on x.parent_object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{NonPartitionedTableName}'
                                                                AND s.name = 'dbo'";

        public static string ConstraintsAfterTableExchangeNonPartitioningOldTable = $@"USE {DatabaseName}
                                                            SELECT ConstraintName = x.Name
                                                            FROM (  SELECT parent_object_id, name
                                                                    FROM sys.check_constraints c
                                                                    UNION ALL
                                                                    SELECT parent_object_id, name
                                                                    FROM sys.default_constraints d) x
                                                                INNER JOIN sys.tables t  on x.parent_object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{NonPartitionedTableName}_OLD'
                                                                AND s.name = 'dbo'";

        public static string ConstraintsAfterRevertTableExchangeNonPartitioningTable = $@"USE {DatabaseName}
                                                            SELECT ConstraintName = x.Name
                                                            FROM (  SELECT parent_object_id, name
                                                                    FROM sys.check_constraints c
                                                                    UNION ALL
                                                                    SELECT parent_object_id, name
                                                                    FROM sys.default_constraints d) x
                                                                INNER JOIN sys.tables t  on x.parent_object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{NonPartitionedTableName}_NewTable'
                                                                AND s.name = 'dbo'";

        public static string StatisticsAfterTableExchangeNonPartitioningNewTable = $@"USE {DatabaseName}
                                                            SELECT StatisticsName = st.Name
                                                            FROM sys.stats st
                                                                INNER JOIN sys.tables t  on st.object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{NonPartitionedTableName}'
                                                                AND s.name = 'dbo'";

        public static string StatisticsAfterTableExchangeNonPartitioningOldTable = $@"USE {DatabaseName}
                                                            SELECT StatisticsName = st.Name
                                                            FROM sys.stats st
                                                                INNER JOIN sys.tables t  on st.object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{NonPartitionedTableName}_OLD'
                                                                AND s.name = 'dbo'";

        public static string StatisticsAfterRevertTableExchangeNonPartitioningTable = $@"USE {DatabaseName}
                                                            SELECT StatisticsName = st.Name
                                                            FROM sys.stats st
                                                                INNER JOIN sys.tables t  on st.object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{NonPartitionedTableName}_NewTable'
                                                                AND s.name = 'dbo'";

        public static string TriggersExistOnLiveTable = $@"USE {DatabaseName}
                                                            SELECT TriggerName = tr.Name
                                                            FROM sys.triggers tr
                                                                INNER JOIN sys.tables t  on tr.parent_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{NonPartitionedTableName}'
                                                                AND s.name = 'dbo'";

        public static string TriggersDoNotExistOnOldTable = $@"USE {DatabaseName}
                                                            SELECT TriggerName = tr.Name
                                                            FROM sys.triggers tr
                                                                INNER JOIN sys.tables t  on tr.parent_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{NonPartitionedTableName}_OLD'
                                                                AND s.name = 'dbo'";

        public static string TriggersDoNotExistOnOfflineTable = $@"USE {DatabaseName}
                                                            SELECT TriggerName = tr.Name
                                                            FROM sys.triggers tr
                                                                INNER JOIN sys.tables t  on tr.parent_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{NonPartitionedTableName}_NewTable'
                                                                AND s.name = 'dbo'";

        public static string RevertTableExchangeUnpartitionedToPriorTable = $@"
                                                        EXEC DOI.spRun_ExchangeTableNonPartitioning_RevertRename
                                                            @DatabaseName = '{DatabaseName}',
		                                                    @SchemaName = 'dbo',
		                                                    @TableName = '{NonPartitionedTableName}'";

        public static string ReRevertTableExchangeUnpartitionedToNewTable = $@"
                                                        EXEC DOI.spRun_ExchangeTableNonPartitioning_ReRevertRename
                                                            @DatabaseName = '{DatabaseName}',
		                                                    @SchemaName = 'dbo',
		                                                    @TableName = '{NonPartitionedTableName}'";

        public static string tearDownSql = $@"
USE DOI

DELETE DOI.DefaultConstraints			WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('{NonPartitionedTableName}','TempB','AAA_SpaceError')
DELETE DOI.[Statistics]					WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('{NonPartitionedTableName}','TempB','AAA_SpaceError')
DELETE DOI.IndexesColumnStore			WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('{NonPartitionedTableName}','TempB','AAA_SpaceError')
DELETE DOI.IndexesRowStore				WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('{NonPartitionedTableName}','TempB','AAA_SpaceError')
DELETE DOI.ForeignKeys					WHERE DatabaseName = 'DOIUnitTests' AND ReferencedTableName		IN ('{NonPartitionedTableName}','TempB','AAA_SpaceError')
DELETE DOI.Tables						WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('{NonPartitionedTableName}','TempB','AAA_SpaceError')
DELETE DOI.Log							WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('{NonPartitionedTableName}','TempB','AAA_SpaceError')


USE DOIUnitTests

DROP TABLE IF EXISTS dbo.{NonPartitionedTableName}
DROP TABLE IF EXISTS dbo.TempB
DROP TABLE IF EXISTS dbo.AAA_SpaceError";
    }
}
