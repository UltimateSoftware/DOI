﻿using System;
using System.Text;

namespace DOI.Tests.TestHelpers
{
    public static class SetupSqlStatements_Partitioned
    {
        private const string DatabaseName = "DOIUnitTests";
        private const string TableName = "PartitioningTestAutomationTable";

        public static string PartitionFunction_Setup_Metadata = $@"
INSERT INTO DOI.PartitionFunctions ( 
				DatabaseName    , PartitionFunctionName			,PartitionFunctionDataType	,BoundaryInterval	,NumOfFutureIntervals	, InitialDate	, UsesSlidingWindow	, SlidingWindowSize	, IsDeprecated  , PartitionSchemeName   , NumOfCharsInSuffix, LastBoundaryDate  , NumOfTotalPartitionFunctionIntervals  , NumOfTotalPartitionSchemeIntervals, MinValueOfDataType)
VALUES		(	'{DatabaseName}'  , 'pfMonthlyTest'				, 'DATETIME2'				, 'Monthly'			, 1					    , '2019-08-01'	, 0					, NULL				, 0             , NULL                  , NULL              , NULL              , NULL                                  , NULL                              , NULL);";

        public static string PartitionFunction_Teardown_Metadata = @"DELETE DOI.PartitionFunctions WHERE DatabaseName = 'DOIUnitTests'";

        public static string TableCreation = $@"
                                        SET ANSI_NULLS ON
                                        SET QUOTED_IDENTIFIER ON

                                        DROP TABLE IF EXISTS [dbo].[{TableName}]

                                        CREATE TABLE [dbo].[{TableName}](
	                                        [Id] [int] NOT NULL,
	                                        [myDateTime] [datetime2](7) NOT NULL,
	                                        [Comments] [nvarchar](100) NULL,
	                                        [updatedUtcDt] [datetime2](7) NOT NULL
                                                CONSTRAINT Chk_{TableName}_updatedUtcDt
                                                    CHECK (updatedUtcDt > '0001-01-01')
                                                CONSTRAINT Def_{TableName}_updatedUtcDt
                                                    DEFAULT SYSDATETIME(),
                                        ) ON [PRIMARY]

                                        CREATE CLUSTERED INDEX [CDX_{TableName}] ON [dbo].[{TableName}]
                                        (
	                                        [myDateTime] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

                                        ALTER TABLE [dbo].[{TableName}] ADD  CONSTRAINT [PK_{TableName}] PRIMARY KEY NONCLUSTERED 
                                        (
	                                        [Id] ASC,
                                            [myDateTime] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

                                        SET ANSI_PADDING ON

                                        CREATE NONCLUSTERED INDEX [IDX_{TableName}_Comments] ON [dbo].[{TableName}]
                                        (
	                                        [Comments] ASC,
                                            [myDateTime] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

                                        CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_{TableName}_Comments] ON [dbo].[{TableName}]
                                        (
	                                        [Comments],
                                            [myDateTime]
                                        )WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]

                                        IF NOT EXISTS (   SELECT 'True'
                                                          FROM   sys.stats
                                                          WHERE  name = 'ST_{TableName}_Comments' )
                                            BEGIN
                                                CREATE STATISTICS ST_{TableName}_Comments
                                                    ON dbo.{TableName} ( Comments )
                                                    WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.                  , MAXDOP = 0*/ ,
                                                         INCREMENTAL = OFF;
                                            END;
                                        IF NOT EXISTS (   SELECT 'True'
                                                          FROM   sys.stats
                                                          WHERE  name = 'ST_{TableName}_id' )
                                            BEGIN
                                                CREATE STATISTICS ST_{TableName}_id
                                                    ON dbo.{TableName} ( Id )
                                                    WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.                  , MAXDOP = 0*/ ,
                                                         INCREMENTAL = OFF;
                                            END;
                                        IF NOT EXISTS (   SELECT 'True'
                                                          FROM   sys.stats
                                                          WHERE  name = 'ST_{TableName}_myDateTime' )
                                            BEGIN
                                                CREATE STATISTICS ST_{TableName}_myDateTime
                                                    ON dbo.{TableName} ( myDateTime )
                                                    WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.                  , MAXDOP = 0*/ ,
                                                         INCREMENTAL = OFF;
                                            END;
                                        IF NOT EXISTS (   SELECT 'True'
                                                          FROM   sys.stats
                                                          WHERE  name = 'ST_{TableName}_updatedUtcDt' )
                                            BEGIN
                                                CREATE STATISTICS ST_{TableName}_updatedUtcDt
                                                    ON dbo.{TableName} ( updatedUtcDt )
                                                    WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.                  , MAXDOP = 0*/ ,
                                                         INCREMENTAL = OFF;
                                            END;";

        public static string CreateTrigger = $@"  CREATE TRIGGER dbo.tr{TableName}_ins  
                                                    ON dbo.{TableName} AFTER insert 
                                                    AS 

                                                    SET NOCOUNT ON
                                                                                                        
                                                    DECLARE @SysDate DATETIME2 = SYSDATETIME()";

        public static string RowStoreIndexes = $@"            
    INSERT INTO DOI.IndexesRowStore (DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, IsFiltered_Desired, FilterPredicate_Desired,Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, PartitionFunction_Desired, PartitionColumn_Desired, Storage_Desired)
                      
    Select 
        DatabaseName                            = N'{DatabaseName}'
        ,SchemaName					            = N'dbo'
        ,TableName                              = N'{TableName}'
        ,IndexName                              = N'CDX_{TableName}'
        ,IsUnique_Desired                       = 0
        ,IsPrimaryKey_Desired                   = 0
        ,IsUniqueConstraint_Desired             = 0
        ,IsClustered_Desired                    = 1
        ,KeyColumnList_Desired                  = N'MyDatetime ASC'
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
        ,PartitionFunction_Desired              = 'pfMonthlyTest'
        ,PartitionColumn_Desired                = 'MyDatetime'
        ,Storage_Desired                        = 'psMonthlyTest'
                     
        UNION  ALL 
                       
	   Select  
        DatabaseName                            = N'{DatabaseName}'
        ,SchemaName					            = N'dbo'
        ,TableName                              = N'{TableName}'
        ,IndexName                              = N'PK_{TableName}'
        ,IsUnique_Desired                       = 1
        ,IsPrimaryKey_Desired                   = 1
        ,IsUniqueConstraint_Desired             = 0
        ,IsClustered_Desired                    = 0
        ,KeyColumnList_Desired                  = N'ID ASC,MyDateTime ASC'
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
        ,PartitionFunction_Desired              = 'pfMonthlyTest'
        ,PartitionColumn_Desired                = 'MyDatetime'
        ,Storage_Desired                        = 'psMonthlyTest'
    
	   UNION ALL
				 
	   Select  
        DatabaseName                            = N'{DatabaseName}'
        ,SchemaName					            = N'dbo'
        ,TableName                              = N'{TableName}'
        ,IndexName                              = N'IDX_{TableName}_Comments'
        ,IsUnique_Desired                       = 0
        ,IsPrimaryKey_Desired                   = 0
        ,IsUniqueConstraint_Desired             = 0
        ,IsClustered_Desired                    = 0
        ,KeyColumnList_Desired                  = N'Comments ASC,MyDatetime ASC'
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
        ,PartitionFunction_Desired              = 'pfMonthlyTest'
        ,PartitionColumn_Desired                = 'MyDatetime'
        ,Storage_Desired                        = 'psMonthlyTest'
                  
                    ";

        public static string ColumnStoreIndexes = $@"
            INSERT INTO DOI.IndexesColumnStore ( DatabaseName, SchemaName ,TableName ,IndexName ,IsClustered_Desired,ColumnList_Desired,IsFiltered_Desired,FilterPredicate_Desired,OptionDataCompression_Desired,OptionDataCompressionDelay_Desired,PartitionFunction_Desired,PartitionColumn_Desired, Storage_Desired )
                    SELECT 
                      [DatabaseName]                = N'{DatabaseName}'
                    , [SchemaName]                  = N'dbo'
                    , [TableName]                   = N'{TableName}'	
                    , [IndexName]                   = N'NCCI_{TableName}_Comments'	
                    , [IsClustered]                 = 0
                    , [ColumnList]                  = N'Comments,MyDatetime'				
                    , [IsFiltered]                  = 0
                    , [FilterPredicate]             = NULL
                    , [OptionDataCompression]       = N'COLUMNSTORE'
                    , [OptionDataCompressionDelay]  = 0
                    , PartitionFunction_Desired     = 'pfMonthlyTest'
                    , PartitionColumn               = 'MyDatetime'
                    , Storage_Desired               = 'psMonthlyTest'
                    ";

        public static string StartJob = @"  exec msdb.dbo.sp_start_job @job_name =  'DOI-Refresh Indexes' ";

        public static string JobActivity = @"exec msdb.dbo.sp_help_jobactivity @job_name =  'DOI-Refresh Indexes'";

        public static string DropTableAndDeleteMetadata = $@"
                        DELETE FROM  [DOI].[Statistics]         WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[CheckConstraints]   WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[DefaultConstraints] WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[IndexesColumnStore] WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[IndexesRowStore]    WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[Tables]		        WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}' AND SchemaName = 'dbo';

                        DECLARE @sql VARCHAR(MAX) = SPACE(0)
                        SELECT @sql += 'DROP TABLE IF EXISTS ' + s.name + '.' + t.name + CHAR(13) + CHAR(10)
                        FROM sys.tables t
                            INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
                        WHERE t.name LIKE '{TableName}%'

                        EXEC(@sql)

                        TRUNCATE TABLE DOI.Log;
                        TRUNCATE TABLE DOI.Queue
                        DELETE PT FROM DOI.Run_PartitionState pt WHERE DatabaseName = '{DatabaseName}' AND pt.ParentTableName = '{TableName}';
                        --EXEC DOI.spRefreshMetadata_Tables;
                        --EXEC DOI.spRefreshMetadata_PartitionFunctions;
                        DELETE DOI.PartitionFunctions WHERE PartitionFunctionName = 'pfMonthlyTest';
                        IF EXISTS(SELECT 'True' FROM sys.partition_schemes WHERE name = 'psMonthlyTest')
                        BEGIN
                            DROP PARTITION SCHEME psMonthlyTest
                        END;
                        IF EXISTS(SELECT 'True' FROM sys.partition_functions WHERE name = 'pfMonthlyTest')
                        BEGIN
                            DROP PARTITION FUNCTION pfMonthlyTest
                        END;";

        public static string TableToMetadata = $@"
            INSERT INTO DOI.Tables
            (
                DatabaseName,
                SchemaName,
                TableName,
                PartitionColumn,
                Storage_Desired,
                StorageType_Desired,
                IntendToPartition,
                ReadyToQueue,
                PartitionFunctionName,
                UpdateTimeStampColumn
            )
            VALUES
            (   '{DatabaseName}',
                'dbo',
                '{TableName}',
                'MyDateTime',
                'psMonthlyTest',
                'PARTITION_SCHEME',
                1,
                1,
                N'pfMonthlyTest',
                'UpdatedUtcDt'
                )";

        public static string StatisticsToMetadata = $@"
                                INSERT INTO DOI.[Statistics] ( DatabaseName, SchemaName, TableName, StatisticsName, StatisticsColumnList_Desired, SampleSizePct_Desired, IsFiltered_Desired, FilterPredicate_Desired, IsIncremental_Desired, NoRecompute_Desired, LowerSampleSizeToDesired, ReadyToQueue)
                                VALUES   ( N'{DatabaseName}', N'dbo', N'{TableName}', 'ST_{TableName}_id', 'id', 20, 0, NULL, 1, 0, 0, 1)
                                        ,( N'{DatabaseName}', N'dbo', N'{TableName}', 'ST_{TableName}_myDateTime', 'myDateTime', 20, 0, NULL, 1, 0, 0, 1)
                                        ,( N'{DatabaseName}', N'dbo', N'{TableName}', 'ST_{TableName}_Comments', 'Comments', 20, 0, NULL, 1, 0, 0, 1)
                                        ,( N'{DatabaseName}', N'dbo', N'{TableName}', 'ST_{TableName}_updatedUtcDt', 'updatedUtcDt', 20, 0, NULL, 1, 0, 0, 1)";

        public static string ConstraintsToMetadata = $@"
                                INSERT INTO DOI.CheckConstraints ( DatabaseName, SchemaName ,TableName ,ColumnName ,CheckDefinition ,IsDisabled ,CheckConstraintName )
                                VALUES ( N'{DatabaseName}', N'dbo', N'{TableName}', N'updatedUtcDt', N'(updatedUtcDt > ''0001-01-01'')', 0, N'Chk_{TableName}_updatedUtcDt')

                                INSERT INTO DOI.DefaultConstraints ( DatabaseName, SchemaName ,TableName ,ColumnName ,DefaultDefinition )
                                VALUES ( N'{DatabaseName}', N'dbo', N'{TableName}', N'updatedUtcDt', N'(SYSDATETIME())')";


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
                    insert.AppendLine($"UNION ALL SELECT {counter}	,'{year}-{month}-15 {DateTime.Now.TimeOfDay}'	,'Record {counter}'		,'{DateTime.Now.AddDays(counter)}'");
                }
            }
            return $"INSERT INTO [dbo].[{TableName}]([Id],[myDateTime],[Comments],[updatedUtcDt])"
                   + Environment.NewLine
                   + insert.ToString().Substring(9);
        }


        public static string CheckLiveTable => GenerateTableExistenceCheckScript(TableName, "dbo");

        public static string CheckOldTable => GenerateTableExistenceCheckScript($"{TableName}_Old", "dbo");

        public static string CheckOfflinePartitionedTable => GenerateTableExistenceCheckScript($"{TableName}_NewPartitionedTableFromPrep", "dbo");
        

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

        public static string DataMismatchValidation = $@"USE {DatabaseName}
                        IF EXISTS(
	                           Select * FROM [dbo].[{TableName}]
	                           EXCEPT
	                           Select * FROM [dbo].[{TableName}_Old]
	                           )
                        OR EXISTS(
                            Select * FROM [dbo].[{TableName}_Old]
                            EXCEPT
                            Select * FROM [dbo].[{TableName}]
                            )
                        BEGIN
                            Select ValidationStatus = 'Error: data mismatch between the new and the old table.'
                        END ";


        public static string RowsInFileGroupsProcedureCall = $@"USE {DatabaseName}
                                        SELECT
                                         TableName = t.name
                                        ,IndexName = i.name
                                        ,SchemaName = s.name
                                        ,RowsInPartition = p.rows
                                        FROM sys.dm_db_partition_stats pts
                                        JOIN sys.tables t ON t.object_id = pts.object_id
                                        JOIN sys.schemas s on s.schema_id = t.schema_id
                                        JOIN sys.indexes i ON i.object_id = pts.object_id
		                                        AND i.index_id = pts.index_id
                                        JOIN sys.partitions p ON pts.object_id = p.object_id
                                            AND pts.index_id = p.index_id
                                            AND pts.partition_number = p.partition_number
                                            AND pts.partition_id = p.partition_id
                                        WHERE t.name =  '{TableName}'
                                        AND  s.name = 'dbo'
                                        AND  i.name = 'CDX_{TableName}' ";


        public static string TotalRowsInFileGroups = $@"USE {DatabaseName}
                                     SELECT
                                     TotalRowsInPartition = Sum(p.rows)
                                    FROM sys.dm_db_partition_stats pts
                                    JOIN sys.tables t ON t.object_id = pts.object_id
                                    JOIN sys.schemas s on s.schema_id = t.schema_id
                                    JOIN sys.indexes i ON i.object_id = pts.object_id
		                                      AND i.index_id = pts.index_id
                                    JOIN sys.partitions p ON pts.object_id = p.object_id
                                        AND pts.index_id = p.index_id
                                        AND pts.partition_number = p.partition_number
                                        AND pts.partition_id = p.partition_id
                                    WHERE t.name =  '{TableName}'
                                    AND  s.name = 'dbo'
                                    AND  i.name = 'CDX_{TableName}'
                                    ";


        public static string DataInPartitionedTable = $@" USE {DatabaseName} Select * from dbo.{TableName}";


        public static string AllPartitionsHaveData = $@"USE {DatabaseName}
                                                        SELECT TOP 1 val = 1
                                                        FROM sys.dm_db_partition_stats pts
                                                        JOIN sys.tables t ON t.object_id = pts.object_id
                                                        JOIN sys.schemas s on s.schema_id = t.schema_id
                                                        JOIN sys.indexes i ON i.object_id = pts.object_id
                                                            AND i.index_id = pts.index_id
                                                        JOIN sys.partitions p ON pts.object_id = p.object_id
                                                            AND pts.index_id = p.index_id
                                                            AND pts.partition_number = p.partition_number
                                                            AND pts.partition_id = p.partition_id
                                                        WHERE t.name =  '{TableName}'
                                                            AND  s.name = 'dbo'
                                                            AND  i.name = 'CDX_{TableName}'
                                                            AND p.rows = 0";

        public static string IndexesAfterPartitioningNewTable = $@"USE {DatabaseName}
                                                        SELECT IndexName = ix.Name
                                                        FROM sys.indexes ix 
                                                            JOIN sys.tables t  on ix.object_id = t.object_id
                                                            JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                        WHERE 1=1
                                                            AND t.name = '{TableName}'
                                                            AND s.name = 'dbo'";

        public static string IndexesAfterPartitioningOldTable = $@"USE {DatabaseName}
                                                        SELECT IndexName = ix.Name
                                                        FROM sys.indexes ix 
                                                            JOIN sys.tables t  on ix.object_id = t.object_id
                                                            JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                        WHERE 1=1
                                                            AND t.name = '{TableName}_OLD'
                                                            AND s.name = 'dbo'";

        public static string IndexesAfterRevertPartitionedTable = $@"USE {DatabaseName}
                                                        SELECT IndexName = ix.Name
                                                        FROM sys.indexes ix 
                                                            JOIN sys.tables t  on ix.object_id = t.object_id
                                                            JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                        WHERE 1=1
                                                            AND t.name = '{TableName}_NewPartitionedTableFromPrep'
                                                            AND s.name = 'dbo'";

        public static string ConstraintsAfterPartitioningNewTable = $@"USE {DatabaseName}
                                                            SELECT ConstraintName = x.Name
                                                            FROM (  SELECT parent_object_id, name
                                                                    FROM sys.check_constraints c
                                                                    UNION ALL
                                                                    SELECT parent_object_id, name
                                                                    FROM sys.default_constraints d) x
                                                                INNER JOIN sys.tables t  on x.parent_object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{TableName}'
                                                                AND s.name = 'dbo'";

        public static string ConstraintsAfterPartitioningOldTable = $@"USE {DatabaseName}
                                                            SELECT ConstraintName = x.Name
                                                            FROM (  SELECT parent_object_id, name
                                                                    FROM sys.check_constraints c
                                                                    UNION ALL
                                                                    SELECT parent_object_id, name
                                                                    FROM sys.default_constraints d) x
                                                                INNER JOIN sys.tables t  on x.parent_object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{TableName}_OLD'
                                                                AND s.name = 'dbo'";

        public static string ConstraintsAfterRevertPartitionedTable = $@"USE {DatabaseName}
                                                            SELECT ConstraintName = x.Name
                                                            FROM (  SELECT parent_object_id, name
                                                                    FROM sys.check_constraints c
                                                                    UNION ALL
                                                                    SELECT parent_object_id, name
                                                                    FROM sys.default_constraints d) x
                                                                INNER JOIN sys.tables t  on x.parent_object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{TableName}_NewPartitionedTableFromPrep'
                                                                AND s.name = 'dbo'";

        public static string StatisticsAfterPartitioningNewTable = $@"USE {DatabaseName}
                                                            SELECT StatisticsName = st.Name
                                                            FROM sys.stats st
                                                                INNER JOIN sys.tables t  on st.object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{TableName}'
                                                                AND s.name = 'dbo'";

        public static string StatisticsAfterPartitioningOldTable = $@"USE {DatabaseName}
                                                            SELECT StatisticsName = st.Name
                                                            FROM sys.stats st
                                                                INNER JOIN sys.tables t  on st.object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{TableName}_OLD'
                                                                AND s.name = 'dbo'";

        public static string StatisticsAfterRevertPartitionedTable = $@"USE {DatabaseName}
                                                            SELECT StatisticsName = st.Name
                                                            FROM sys.stats st
                                                                INNER JOIN sys.tables t  on st.object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{TableName}_NewPartitionedTableFromPrep'
                                                                AND s.name = 'dbo'";

        public static string TriggersExistOnLiveTable = $@"USE {DatabaseName}
                                                            SELECT TriggerName = tr.Name
                                                            FROM sys.triggers tr
                                                                INNER JOIN sys.tables t  on tr.parent_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{TableName}'
                                                                AND s.name = 'dbo'";

        public static string TriggersDoNotExistOnOldTable = $@"USE {DatabaseName}
                                                            SELECT TriggerName = tr.Name
                                                            FROM sys.triggers tr
                                                                INNER JOIN sys.tables t  on tr.parent_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{TableName}_OLD'
                                                                AND s.name = 'dbo'";

        public static string TriggersDoNotExistOnOfflineTable = $@"USE {DatabaseName}
                                                            SELECT TriggerName = tr.Name
                                                            FROM sys.triggers tr
                                                                INNER JOIN sys.tables t  on tr.parent_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = '{TableName}_NewPartitionedTableFromPrep'
                                                                AND s.name = 'dbo'";

        public static string PartitionStateMetadata = $@"
                                                    INSERT INTO DOI.Run_PartitionState ( DatabaseName, SchemaName ,ParentTableName , PrepTableName, PartitionFromValue ,PartitionToValue ,DataSynchState ,LastUpdateDateTime )
                                                    SELECT DatabaseName, SchemaName, ParentTableName, UnPartitionedPrepTableName, PartitionFunctionValue, NextPartitionFunctionValue, 0, GETDATE()
                                                    FROM DOI.vwPartitioning_Tables_PrepTables_Partitions FN
                                                    WHERE ParentTableName IN ('{TableName}')
	                                                    AND NOT EXISTS (SELECT 'True' 
					                                                    FROM DOI.Run_PartitionState PS 
					                                                    WHERE PS.DatabaseName = FN.DatabaseName
                                                                            AND PS.SchemaName = FN.SchemaName
						                                                    AND PS.ParentTableName = FN.ParentTableName
						                                                    AND PS.PrepTableName = FN.UnPartitionedPrepTableName)

                                                    DELETE PS
                                                    FROM DOI.Run_PartitionState PS
                                                    WHERE NOT EXISTS(	SELECT 'True' 
					                                                    FROM DOI.Run_PartitionState PS2
					                                                    WHERE PS.DatabaseName = PS2.DatabaseName
                                                                            AND PS.SchemaName = PS2.SchemaName
						                                                    AND PS.ParentTableName = PS2.ParentTableName
						                                                    AND PS.PrepTableName = PS2.PrepTableName)";

        public static string DetailsOfLastJobRun = @"
                                                    DECLARE @LatestRunDate varchar(10)
                                                    DECLARE @LatestRunTime varchar(10)
                                                        
                                                    select @LatestRunDate = max(jh.run_date) 
                                                        , @LatestRunTime =  max(jh.run_time ) 
                                                    from msdb.dbo.sysjobs j
                                                    JOIN msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
                                                    where  j.name = N'DOI-Refresh Indexes'
                                                        AND jh.step_id = 1

                                                    select jh. step_id,  step_name , message , sql_severity, run_date , run_time, run_status
                                                    from msdb.dbo.sysjobs j
                                                    JOIN msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
                                                    where  j.name = N'Refresh Index Structures'
                                                    and jh.run_date >= @LatestRunDate 
                                                    AND jh.run_time >= @LatestRunTime";

        public static string CheckForEmptyPartitionStateMetadata(string schemaName, string tableName)
        {
            return $@"
            SELECT 1 FROM DOI.Run_PartitionState
            WHERE SchemaName = '{schemaName}'
            AND ParentTableName = '{tableName}'";   
        }

        public static string RevertPartitioningToUnpartitionedTable = $@"
                                                        EXEC DOI.spRun_Partitioning_RevertRename
                                                            @DatabaseName = '{DatabaseName}',
		                                                    @SchemaName = 'dbo',
		                                                    @TableName = '{TableName}'";

        public static string ReRevertPartitioningToPartitionedTable = $@"
                                                        EXEC DOI.spRun_Partitioning_ReRevertRename
                                                            @DatabaseName = '{DatabaseName}',
		                                                    @SchemaName = 'dbo',
		                                                    @TableName = '{TableName}'";
    }
}