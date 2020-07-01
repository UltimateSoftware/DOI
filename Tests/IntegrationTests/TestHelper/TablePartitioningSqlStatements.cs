using System;
using System.Text;

namespace DOI.TestHelpers
{
    public static class TablePartitioningSqlStatements
    {
        public static string PartitionFunctionCreation = @"
INSERT INTO DOI.PartitionFunctions ( 
				PartitionFunctionName			,PartitionFunctionDataType	,BoundaryInterval	,NumOfFutureIntervals	, InitialDate	, UsesSlidingWindow	, SlidingWindowSize	, IsDeprecated)
VALUES		(	'pfMonthlyTest'					, 'DATETIME2'				, 'Monthly'			, 1					    , '2019-08-01'	, 0					, NULL				, 0);

EXEC DOI.spRefreshStorageContainers_PartitionFunctions
	@PartitionFunctionName = 'pfMonthlyTest';

EXEC DOI.spRefreshStorageContainers_PartitionSchemes
    @PartitionFunctionName = 'pfMonthlyTest';
";


        public static string TableCreation = @"
                                        SET ANSI_NULLS ON
                                        SET QUOTED_IDENTIFIER ON

                                        DROP TABLE IF EXISTS [dbo].[PartitioningTestAutomationTable]

                                        CREATE TABLE [dbo].[PartitioningTestAutomationTable](
	                                        [Id] [int] NOT NULL,
	                                        [myDateTime] [datetime2](7) NOT NULL,
	                                        [Comments] [nvarchar](100) NULL,
	                                        [updatedUtcDt] [datetime2](7) NOT NULL
                                                CONSTRAINT Chk_PartitioningTestAutomationTable_updatedUtcDt
                                                    CHECK (updatedUtcDt > '0001-01-01')
                                                CONSTRAINT Def_PartitioningTestAutomationTable_updatedUtcDt
                                                    DEFAULT SYSDATETIME(),
                                        ) ON [PRIMARY]

                                        CREATE CLUSTERED INDEX [CDX_PartitioningTestAutomationTable] ON [dbo].[PartitioningTestAutomationTable]
                                        (
	                                        [myDateTime] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

                                        ALTER TABLE [dbo].[PartitioningTestAutomationTable] ADD  CONSTRAINT [PK_PartitioningTestAutomationTable] PRIMARY KEY NONCLUSTERED 
                                        (
	                                        [Id] ASC,
                                            [myDateTime] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

                                        SET ANSI_PADDING ON

                                        CREATE NONCLUSTERED INDEX [IDX_PartitioningTestAutomationTable_Comments] ON [dbo].[PartitioningTestAutomationTable]
                                        (
	                                        [Comments] ASC,
                                            [myDateTime] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

                                        CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_PartitioningTestAutomationTable_Comments] ON [dbo].[PartitioningTestAutomationTable]
                                        (
	                                        [Comments],
                                            [myDateTime]
                                        )WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]

                                        IF NOT EXISTS (   SELECT 'True'
                                                          FROM   sys.stats
                                                          WHERE  name = 'ST_PartitioningTestAutomationTable_Comments' )
                                            BEGIN
                                                CREATE STATISTICS ST_PartitioningTestAutomationTable_Comments
                                                    ON dbo.PartitioningTestAutomationTable ( Comments )
                                                    WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.                  , MAXDOP = 0*/ ,
                                                         INCREMENTAL = OFF;
                                            END;
                                        IF NOT EXISTS (   SELECT 'True'
                                                          FROM   sys.stats
                                                          WHERE  name = 'ST_PartitioningTestAutomationTable_id' )
                                            BEGIN
                                                CREATE STATISTICS ST_PartitioningTestAutomationTable_id
                                                    ON dbo.PartitioningTestAutomationTable ( Id )
                                                    WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.                  , MAXDOP = 0*/ ,
                                                         INCREMENTAL = OFF;
                                            END;
                                        IF NOT EXISTS (   SELECT 'True'
                                                          FROM   sys.stats
                                                          WHERE  name = 'ST_PartitioningTestAutomationTable_myDateTime' )
                                            BEGIN
                                                CREATE STATISTICS ST_PartitioningTestAutomationTable_myDateTime
                                                    ON dbo.PartitioningTestAutomationTable ( myDateTime )
                                                    WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.                  , MAXDOP = 0*/ ,
                                                         INCREMENTAL = OFF;
                                            END;
                                        IF NOT EXISTS (   SELECT 'True'
                                                          FROM   sys.stats
                                                          WHERE  name = 'ST_PartitioningTestAutomationTable_updatedUtcDt' )
                                            BEGIN
                                                CREATE STATISTICS ST_PartitioningTestAutomationTable_updatedUtcDt
                                                    ON dbo.PartitioningTestAutomationTable ( updatedUtcDt )
                                                    WITH SAMPLE 20 PERCENT /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.                  , MAXDOP = 0*/ ,
                                                         INCREMENTAL = OFF;
                                            END;";

        public static string RowStoreIndexes = @"            
    INSERT INTO DOI.IndexesRowStore (DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, IsFiltered_Desired, FilterPredicate_Desired,Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, Storage_Desired, PartitionColumn_Desired)
                      
    Select 
        SchemaName					 = N'dbo'
        ,TableName                      = N'PartitioningTestAutomationTable'
        ,IndexName                      = N'CDX_PartitioningTestAutomationTable'
        ,IsUnique                       = 0
        ,IsPrimaryKey                   = 0
        ,IsUniqueConstraint             = 0
        ,IsClustered                    = 1
        ,KeyColumnList                  = N'MyDatetime ASC'
        ,IncludedColumnList             = NULL
        ,IsFiltered                     = 0
        ,FilterPredicate                = NULL
        ,[Fillfactor]                   = 80
        ,OptionPadIndex                 = 1
        ,OptionStatisticsNoRecompute    = 0
        ,OptionStatisticsIncremental    = 0
        ,OptionIgnoreDupKey             = 0
        ,OptionResumable                = 0
        ,OptionMaxDuration              = 0
        ,OptionAllowRowLocks            = 1
        ,OptionAllowPageLocks           = 1
        ,OptionDataCompression          = 'PAGE'
        ,NewStorage                     = 'psMonthlyTest'
        ,PartitionColumn                = 'MyDatetime'
                     
        UNION  ALL 
                       
	   Select 
        SchemaName					 = N'dbo'
        ,TableName                      = N'PartitioningTestAutomationTable'
        ,IndexName                      = N'PK_PartitioningTestAutomationTable'
        ,IsUnique                       = 1
        ,IsPrimaryKey                   = 1
        ,IsUniqueConstraint             = 0
        ,IsClustered                    = 0
        ,KeyColumnList                  = N'ID ASC,MyDateTime ASC'
        ,IncludedColumnList             = NULL
        ,IsFiltered                     = 0
        ,FilterPredicate                = NULL
        ,[Fillfactor]                   = 80
        ,OptionPadIndex                 = 1
        ,OptionStatisticsNoRecompute    = 0
        ,OptionStatisticsIncremental    = 0
        ,OptionIgnoreDupKey             = 0
        ,OptionResumable                = 0
        ,OptionMaxDuration              = 0
        ,OptionAllowRowLocks            = 1
        ,OptionAllowPageLocks           = 1
        ,OptionDataCompression          = 'PAGE'
        ,NewStorage                     = 'psMonthlyTest'
        ,PartitionColumn                = 'MyDatetime'
                     
	   UNION ALL
				 
	   Select 
        SchemaName					 = N'dbo'
        ,TableName                      = N'PartitioningTestAutomationTable'
        ,IndexName                      = N'IDX_PartitioningTestAutomationTable_Comments'
        ,IsUnique                       = 0
        ,IsPrimaryKey                   = 0
        ,IsUniqueConstraint             = 0
        ,IsClustered                    = 0
        ,KeyColumnList                  = N'Comments ASC,MyDatetime ASC'
        ,IncludedColumnList             = NULL
        ,IsFiltered                     = 0
        ,FilterPredicate                = NULL
        ,[Fillfactor]                   = 80
        ,OptionPadIndex                 = 1
        ,OptionStatisticsNoRecompute    = 0
        ,OptionStatisticsIncremental    = 0
        ,OptionIgnoreDupKey             = 0
        ,OptionResumable                = 0
        ,OptionMaxDuration              = 0
        ,OptionAllowRowLocks            = 1
        ,OptionAllowPageLocks           = 1
        ,OptionDataCompression          = 'PAGE'
        ,NewStorage                     = 'psMonthlyTest'
        ,PartitionColumn                = 'MyDatetime'
                  
                    ";

        public static string ColumnStoreIndexes = @"
            INSERT INTO DOI.IndexesColumnStore ( SchemaName ,TableName ,IndexName ,IsClustered_Desired,ColumnList_Desired,IsFiltered_Desired,FilterPredicate_Desired,OptionDataCompression_Desired,OptionDataCompressionDelay_Desired_Desired,NewStorage_Desired,PartitionColumn_Desired )
                    SELECT 
                      [DatabaseName]            = N'PaymentReporting'
                    , [SchemaName]              = N'dbo'
                    , [TableName]               = N'PartitioningTestAutomationTable'	
                    , [IndexName]               = N'NCCI_PartitioningTestAutomationTable_Comments'	
                    , [IsClustered]             = 0
                    , [ColumnList]              = N'Comments,MyDatetime'				
                    , [IsFiltered]              = 0
                    , [FilterPredicate]         = NULL
                    , [OptionDataCompression]   = N'COLUMNSTORE'
                    , [OptionDataCompressionDelay]  = 0
                    , NewStorage                = 'psMonthlyTest'
                    , PartitionColumn           = 'MyDatetime'
                    ";

        public static string StartJob = @"  exec msdb.dbo.sp_start_job          @job_name =  'Refresh Index Structures - Online' ";

        public static string JobActivity = @"exec msdb.dbo.sp_help_jobactivity @job_name =  'Refresh Index Structures - Online'";

        public static string DropTableAndDeleteMetadata = @"
                        DELETE FROM  [DOI].[Statistics]         WHERE DatabaseName = 'PaymentReporting' AND TableName = 'PartitioningTestAutomationTable' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[CheckConstraints]   WHERE DatabaseName = 'PaymentReporting' AND TableName = 'PartitioningTestAutomationTable' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[DefaultConstraints] WHERE DatabaseName = 'PaymentReporting' AND TableName = 'PartitioningTestAutomationTable' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[IndexesColumnStore] WHERE DatabaseName = 'PaymentReporting' AND TableName = 'PartitioningTestAutomationTable' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[IndexesRowStore]    WHERE DatabaseName = 'PaymentReporting' AND TableName = 'PartitioningTestAutomationTable' AND SchemaName = 'dbo';
                        DELETE FROM  [DOI].[Tables]		        WHERE DatabaseName = 'PaymentReporting' AND TableName = 'PartitioningTestAutomationTable' AND SchemaName = 'dbo';

                        DECLARE @sql VARCHAR(MAX) = SPACE(0)
                        SELECT @sql += 'DROP TABLE IF EXISTS ' + s.name + '.' + t.name + CHAR(13) + CHAR(10)
                        FROM sys.tables t
                            INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
                        WHERE t.name LIKE 'PartitioningTestAutomationTable%'

                        EXEC(@sql)

                        TRUNCATE TABLE DOI.Log;
                        TRUNCATE TABLE DOI.Queue
                        DELETE PT FROM DOI.Run_PartitionState pt WHERE DatabaseName = 'PaymentReporting' AND pt.ParentTableName = 'PartitioningTestAutomationTable';
                        EXEC DOI.spRefreshMetadata_Tables;
                        EXEC DOI.spRefreshMetadata_PartitionFunctions;
                        DELETE DOI.PartitionFunctions WHERE PartitionFunctionName = 'pfMonthlyTest';
                        IF EXISTS(SELECT 'True' FROM sys.partition_schemes WHERE name = 'psMonthlyTest')
                        BEGIN
                            DROP PARTITION SCHEME psMonthlyTest
                        END;
                        IF EXISTS(SELECT 'True' FROM sys.partition_functions WHERE name = 'pfMonthlyTest')
                        BEGIN
                            DROP PARTITION FUNCTION pfMonthlyTest
                        END;";


        public static string TableToMetadata = @"
                                INSERT INTO DOI.Tables
                                (DatabaseName,
                                 SchemaName,
                                 TableName,
                                 PartitionColumn_Desired,
                                 Storage_Desired,
                                 IntendToPartition,
                                 ReadyToQueue
                                )
                                VALUES
                                ('PaymentReporting',
                                 'dbo',
                                 'PartitioningTestAutomationTable',
                                 'MyDateTime',
                                 'psMonthlyTest',
                                 1,
                                 1
                                );  ";

        public static string StatisticsToMetadata = @"
                                INSERT INTO DOI.[Statistics] ( DatabaseName, SchemaName, TableName, StatisticsName, StatisticsColumnList_Desired, SampleSizePct_Desired, IsFiltered_Desired, FilterPredicate_Desired, IsIncremental_Desired, NoRecompute_Desired, LowerSampleSizeToDesired, ReadyToQueue)
                                VALUES   ( N'PaymentReporting', N'dbo', N'PartitioningTestAutomationTable', 'ST_PartitioningTestAutomationTable_id', 'id', 20, 0, NULL, 1, 0, 0, 1)
                                        ,( N'PaymentReporting', N'dbo', N'PartitioningTestAutomationTable', 'ST_PartitioningTestAutomationTable_myDateTime', 'myDateTime', 20, 0, NULL, 1, 0, 0, 1)
                                        ,( N'PaymentReporting', N'dbo', N'PartitioningTestAutomationTable', 'ST_PartitioningTestAutomationTable_Comments', 'Comments', 20, 0, NULL, 1, 0, 0, 1)
                                        ,( N'PaymentReporting', N'dbo', N'PartitioningTestAutomationTable', 'ST_PartitioningTestAutomationTable_updatedUtcDt', 'updatedUtcDt', 20, 0, NULL, 1, 0, 0, 1)";

        public static string ConstraintsToMetadata = @"
                                INSERT INTO DOI.CheckConstraints ( DatabaseName, SchemaName ,TableName ,ColumnName ,CheckDefinition ,IsDisabled ,CheckConstraintName )
                                VALUES ( N'PaymentReporting', N'dbo', N'PartitioningTestAutomationTable', N'updatedUtcDt', N'(updatedUtcDt > ''0001-01-01'')', 0, N'Chk_PartitioningTestAutomationTable_updatedUtcDt')

                                INSERT INTO DOI.DefaultConstraints ( DatabaseName, SchemaName ,TableName ,ColumnName ,DefaultDefinition )
                                VALUES ( N'PaymentReporting', N'dbo', N'PartitioningTestAutomationTable', N'updatedUtcDt', N'(SYSDATETIME())')";


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
            return "INSERT INTO [dbo].[PartitioningTestAutomationTable]([Id],[myDateTime],[Comments],[updatedUtcDt])"
                   + Environment.NewLine
                   + insert.ToString().Substring(9);
        }


        public static string CheckNewTable => GenerateTableExistenceCheckScript("PartitioningTestAutomationTable", "dbo");

        public static string CheckOldTable => GenerateTableExistenceCheckScript("PartitioningTestAutomationTable_Old", "dbo");

        private static string GenerateTableExistenceCheckScript(string tablename, string schemaname)
        {
            return $@"USE PaymentReporting
                        SELECT 1
                        FROM sys.tables t 
                        JOIN sys.schemas s on s.schema_id = t.schema_id
                        WHERE 1=1 
                        AND	t.name = '{tablename}' 
                        AND	s.name = '{schemaname}' ";
        }

        public static string DataMismatchValidation = @"USE PaymentReporting
                        IF EXISTS(
	                           Select * FROM [dbo].[PartitioningTestAutomationTable]
	                           EXCEPT
	                           Select * FROM [dbo].[PartitioningTestAutomationTable_Old]
	                           )
                        OR EXISTS(
                            Select * FROM [dbo].[PartitioningTestAutomationTable_Old]
                            EXCEPT
                            Select * FROM [dbo].[PartitioningTestAutomationTable]
                            )
                        BEGIN
                            Select ValidationStatus = 'Error: data mismatch between the new and the old table.'
                        END ";


        public static string RowsInFileGroupsProcedureCall = @"USE PaymentReporting
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
                                        WHERE t.name =  'PartitioningTestAutomationTable'
                                        AND  s.name = 'dbo'
                                        AND  i.name = 'CDX_PartitioningTestAutomationTable' ";


        public static string TotalRowsInFileGroups = @"USE PaymentReporting
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
                                    WHERE t.name =  'PartitioningTestAutomationTable'
                                    AND  s.name = 'dbo'
                                    AND  i.name = 'CDX_PartitioningTestAutomationTable'
                                    ";

        public static string UpdateJobStepForTest = @"
                                                    EXEC msdb.dbo.sp_update_jobstep  
                                                     @job_name =  'Refresh Index Structures - Online' 
                                                    ,@step_id = 2
                                                    ,@step_name = 'Populate Index Structures Queue - Online'
                                                    ,@command = N' 
                                                           DECLARE @BatchId UNIQUEIDENTIFIER
                                                           
	                                                       TRUNCATE TABLE DOI.Queue
	                                                       EXEC DOI.spQueue 
			                                                    @OnlineOperations = 1,
			                                                    @IsBeingRunDuringADeployment = 0,
                                                                @BatchIdOUT = @BatchId OUTPUT'
                                                    ";

        public static string RestoreJobStep = @"
                                                    EXEC msdb.dbo.sp_update_jobstep  
                                                     @job_name =  'Refresh Index Structures - Online' 
                                                    ,@step_id = 2
                                                    ,@step_name = 'Populate Index Structures Queue - Online'
                                                    ,@command = N' 
	                                                       DECLARE @BatchId UNIQUEIDENTIFIER
                                                           
	                                                       TRUNCATE TABLE DOI.Queue
	                                                       EXEC DOI.spQueue 
			                                                    @OnlineOperations = 1,
			                                                    @IsBeingRunDuringADeployment = 0,
                                                                @BatchIdOUT = @BatchId OUTPUT '
                                                    ";

        public static string DataInPartitionedTable = @" USE PaymentReporting Select * from dbo.PartitioningTestAutomationTable";


        public static string AllPartitionsHaveData = @"USE PaymentReporting
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
                                                        WHERE t.name =  'PartitioningTestAutomationTable'
                                                            AND  s.name = 'dbo'
                                                            AND  i.name = 'CDX_PartitioningTestAutomationTable'
                                                            AND p.rows = 0";

        public static string IndexesAfterPartitioningNewTable = @"USE PaymentReporting
                                                        SELECT IndexName = ix.Name
                                                        FROM sys.indexes ix 
                                                            JOIN sys.tables t  on ix.object_id = t.object_id
                                                            JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                        WHERE 1=1
                                                            AND t.name = 'PartitioningTestAutomationTable'
                                                            AND s.name = 'dbo'";

        public static string IndexesAfterPartitioningOldTable = @"USE PaymentReporting
                                                        SELECT IndexName = ix.Name
                                                        FROM sys.indexes ix 
                                                            JOIN sys.tables t  on ix.object_id = t.object_id
                                                            JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                        WHERE 1=1
                                                            AND t.name = 'PartitioningTestAutomationTable_OLD'
                                                            AND s.name = 'dbo'";

        public static string ConstraintsAfterPartitioningNewTable = @"USE PaymentReporting
                                                            SELECT ConstraintName = x.Name
                                                            FROM (  SELECT parent_object_id, name
                                                                    FROM sys.check_constraints c
                                                                    UNION ALL
                                                                    SELECT parent_object_id, name
                                                                    FROM sys.default_constraints d) x
                                                                INNER JOIN sys.tables t  on x.parent_object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = 'PartitioningTestAutomationTable'
                                                                AND s.name = 'dbo'";

        public static string ConstraintsAfterPartitioningOldTable = @"USE PaymentReporting
                                                            SELECT ConstraintName = x.Name
                                                            FROM (  SELECT parent_object_id, name
                                                                    FROM sys.check_constraints c
                                                                    UNION ALL
                                                                    SELECT parent_object_id, name
                                                                    FROM sys.default_constraints d) x
                                                                INNER JOIN sys.tables t  on x.parent_object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = 'PartitioningTestAutomationTable_OLD'
                                                                AND s.name = 'dbo'";

        public static string StatisticsAfterPartitioningNewTable = @"USE PaymentReporting
                                                            SELECT StatisticsName = st.Name
                                                            FROM sys.stats st
                                                                INNER JOIN sys.tables t  on st.object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = 'PartitioningTestAutomationTable'
                                                                AND s.name = 'dbo'";

        public static string StatisticsAfterPartitioningOldTable = @"USE PaymentReporting
                                                            SELECT StatisticsName = st.Name
                                                            FROM sys.stats st
                                                                INNER JOIN sys.tables t  on st.object_id = t.object_id
                                                                INNER JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                            WHERE t.name = 'PartitioningTestAutomationTable_OLD'
                                                                AND s.name = 'dbo'";

        public static string RecordsInTheQueue = @"Select * FROM  DOI.Queue WHERE IsOnlineOperation = 1";

        public static string LogHasNoErrors = @"SELECT * FROM DOI.Log WHERE SchemaName = 'dbo' and TableName = 'PartitioningTestAutomationTable' and ErrorText IS NOT NULL";

        public static string PartitionStateMetadata = @"
                                                    INSERT INTO DOI._PartitionState ( SchemaName ,ParentTableName , PrepTableName, PartitionFromValue ,PartitionToValue ,DataSynchState ,LastUpdateDateTime )
                                                    SELECT SchemaName, ParentTableName, UnPartitionedPrepTableName, PartitionFunctionValue, NextPartitionFunctionValue, 0, GETDATE()
                                                    FROM DOI.fnDataDrivenIndexes_GetPartitionSQL () FN
                                                    WHERE ParentTableName IN ('PartitioningTestAutomationTable')
	                                                    AND NOT EXISTS (SELECT 'True' 
					                                                    FROM DOI._PartitionState PS 
					                                                    WHERE PS.SchemaName = FN.SchemaName
						                                                    AND PS.ParentTableName = FN.ParentTableName
						                                                    AND PS.PrepTableName = FN.UnPartitionedPrepTableName)

                                                    DELETE PS
                                                    FROM DOI._PartitionState PS
                                                    WHERE NOT EXISTS(	SELECT 'True' 
					                                                    FROM DOI._PartitionState PS2
					                                                    WHERE PS.SchemaName = PS2.SchemaName
						                                                    AND PS.ParentTableName = PS2.ParentTableName
						                                                    AND PS.PrepTableName = PS2.PrepTableName)";

        public static string DetailsOfLastJobRun = @"
                                                    DECLARE @LatestRunDate varchar(10)
                                                    DECLARE @LatestRunTime varchar(10)
                                                        
                                                    select @LatestRunDate = max(jh.run_date) 
                                                        , @LatestRunTime =  max(jh.run_time ) 
                                                    from msdb.dbo.sysjobs j
                                                    JOIN msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
                                                    where  j.name = N'Refresh Index Structures - Online'
                                                        AND jh.step_id = 1

                                                    select jh. step_id,  step_name , message , sql_severity, run_date , run_time, run_status
                                                    from msdb.dbo.sysjobs j
                                                    JOIN msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
                                                    where  j.name = N'Refresh Index Structures - Online'
                                                    and jh.run_date >= @LatestRunDate 
                                                    AND jh.run_time >= @LatestRunTime";

        public static string CheckForEmptyPartitionStateMetadata(string schemaName, string tableName)
        {
            return $@"
            SELECT 1 FROM DOI._PartitionState
            WHERE SchemaName = '{schemaName}'
            AND ParentTableName = '{tableName}'";   
        }
    }
}