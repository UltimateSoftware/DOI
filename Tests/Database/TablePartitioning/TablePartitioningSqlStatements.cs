using System;
using System.Text;

namespace Reporting.Ingestion.Integration.Tests.Database.TablePartitioning
{
    public static class TablePartitioningSqlStatements
    {
        public static string PartitionFunctionCreation = @"
INSERT INTO Utility.PartitionFunctions ( 
				PartitionFunctionName			,PartitionFunctionDataType	,BoundaryInterval	,NumOfFutureIntervals	, InitialDate	, UsesSlidingWindow	, SlidingWindowSize	, IsDeprecated)
VALUES		(	'pfMonthlyTest'					, 'DATETIME2'				, 'Monthly'			, 1					    , '2019-08-01'	, 0					, NULL				, 0);

EXEC Utility.spPartitionFunctionCreate
	@PartitionFunctionName = 'pfMonthlyTest';

EXEC Utility.spPartitionSchemeCreate
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
	                                        [updatedUtcDt] [datetime2](7) NOT NULL,
                                        ) ON [PRIMARY]

                                        CREATE CLUSTERED INDEX [CDX_myDateTime] ON [dbo].[PartitioningTestAutomationTable]
                                        (
	                                        [myDateTime] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

                                        ALTER TABLE [dbo].[PartitioningTestAutomationTable] ADD  CONSTRAINT [PK_PartitioningTestAutomationTable] PRIMARY KEY NONCLUSTERED 
                                        (
	                                        [Id] ASC,
                                            [myDateTime] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

                                        SET ANSI_PADDING ON

                                        CREATE NONCLUSTERED INDEX [NonClusteredIndex_Comments] ON [dbo].[PartitioningTestAutomationTable]
                                        (
	                                        [Comments] ASC,
                                            [myDateTime] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

                                        CREATE NONCLUSTERED COLUMNSTORE INDEX [NonClusteredColumnStoreIndex_Comments] ON [dbo].[PartitioningTestAutomationTable]
                                        (
	                                        [Comments],
                                            [myDateTime]
                                        )WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]";

        public static string RowStoreIndexes = @"            
    INSERT INTO Utility.IndexesRowStore (SchemaName,TableName,IndexName,IsUnique,IsPrimaryKey,IsUniqueConstraint,IsClustered,KeyColumnList,IncludedColumnList,IsFiltered,FilterPredicate,[Fillfactor],OptionPadIndex,OptionStatisticsNoRecompute,OptionStatisticsIncremental,OptionIgnoreDupKey,OptionResumable,OptionMaxDuration,OptionAllowRowLocks,OptionAllowPageLocks,OptionDataCompression,NewStorage,PartitionColumn)
                      
    Select 
        SchemaName					 = N'dbo'
        ,TableName                      = N'PartitioningTestAutomationTable'
        ,IndexName                      = N'CDX_myDateTime'
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
        ,KeyColumnList                  = N'ID ASC, MyDateTime ASC'
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
        ,IndexName                      = N'NonClusteredIndex_Comments'
        ,IsUnique                       = 0
        ,IsPrimaryKey                   = 0
        ,IsUniqueConstraint             = 0
        ,IsClustered                    = 0
        ,KeyColumnList                  = N'Comments ASC, MyDatetime ASC'
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
                    INSERT [Utility].[IndexesColumnStore] ([SchemaName], [TableName], [IndexName], [IsClustered], [ColumnList], [IsFiltered], [FilterPredicate], [OptionDataCompression], [OptionCompressionDelay], NewStorage, PartitionColumn) 
                    SELECT 
                      [SchemaName]              = N'dbo'
                    , [TableName]               = N'PartitioningTestAutomationTable'	
                    , [IndexName]               = N'NonClusteredColumnStoreIndex_Comments'	
                    , [IsClustered]             = 0
                    , [ColumnList]              = N'Comments, MyDatetime'				
                    , [IsFiltered]              = 0
                    , [FilterPredicate]         = NULL
                    , [OptionDataCompression]   = N'COLUMNSTORE'
                    , [OptionCompressionDelay]  = 0
                    , NewStorage                = 'psMonthlyTest'
                    , PartitionColumn           = 'MyDatetime'
                    ";

        public static string StartJob = @"  exec msdb.dbo.sp_start_job          @job_name =  'Refresh Index Structures' ";

        public static string JobActivity = @"exec msdb.dbo.sp_help_jobactivity @job_name =  'Refresh Index Structures'";

        public static string DropTableAndDeleteMetadata = @"
                        DELETE FROM  [Utility].[IndexesColumnStore] WHERE TableName = 'PartitioningTestAutomationTable' AND SchemaName = 'dbo';
                        DELETE FROM  [Utility].[IndexesRowStore]    WHERE TableName = 'PartitioningTestAutomationTable' AND SchemaName = 'dbo';
                        DELETE FROM  [Utility].[Tables]		    WHERE TableName = 'PartitioningTestAutomationTable' AND SchemaName = 'dbo';
                        DROP TABLE IF EXISTS DBO.PartitioningTestAutomationTable;
                        DROP TABLE IF EXISTS DBO.PartitioningTestAutomationTable_Old;
                        TRUNCATE TABLE Utility.RefreshIndexStructuresLog;
                        TRUNCATE TABLE Utility.RefreshIndexStructuresQueue
                        DELETE PT FROM Utility.RefreshIndexStructures_PartitionState pt WHERE pt.ParentTableName = 'PartitioningTestAutomationTable';
                        EXEC Utility.spDDI_RefreshMetadata_Tables;
                        EXEC Utility.spDDI_RefreshMetadata_PartitionFunctions;
                        DELETE Utility.PartitionFunctions WHERE PartitionFunctionName = 'pfMonthlyTest';
                        IF EXISTS(SELECT 'True' FROM sys.partition_schemes WHERE name = 'psMonthlyTest')
                        BEGIN
                            DROP PARTITION SCHEME psMonthlyTest
                        END;
                        IF EXISTS(SELECT 'True' FROM sys.partition_functions WHERE name = 'pfMonthlyTest')
                        BEGIN
                            DROP PARTITION FUNCTION pfMonthlyTest
                        END;";


        public static string TableToMetadata = @"
                                INSERT INTO Utility.Tables
                                (SchemaName,
                                 TableName,
                                 PartitionColumn,
                                 NewStorage,
                                 UseBCPStrategy,
                                 IntendToPartition,
                                 EnableRunPartitioning,
                                 ReadyToQueue
                                )
                                VALUES
                                ('dbo',
                                 'PartitioningTestAutomationTable',
                                 'MyDateTime',
                                 'psMonthlyTest',
                                 1,
                                 1,
                                 0,
                                 1
                                );  ";
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
            return $@"
                        SELECT 1
                        FROM sys.tables t 
                        JOIN sys.schemas s on s.schema_id = t.schema_id
                        WHERE 1=1 
                        AND	t.name = '{tablename}' 
                        AND	s.name = '{schemaname}' ";
        }

        public static string DataMismatchValidation = @"
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


        public static string RowsInFileGroupsProcedureCall = @"
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
                                        AND  i.name = 'CDX_myDateTime' ";


        public static string TotalRowsInFileGroups = @"
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
                                    AND  i.name = 'CDX_myDateTime'
                                    ";

        public static string UpdateJobStepForTest = @"
                                                    EXEC msdb.dbo.sp_update_jobstep  
                                                     @job_name =  'Refresh Index Structures' 
                                                    ,@step_id = 2
                                                    ,@step_name = 'Populate Index Structures Queue'
                                                    ,@command = N' 
                                                           DECLARE @BatchId UNIQUEIDENTIFIER
                                                           
	                                                       TRUNCATE TABLE Utility.RefreshIndexStructuresQueue
	                                                       EXEC Utility.spRefreshIndexStructures_Queue 
			                                                    @OnlineOperations = 1,
			                                                    @IsBeingRunDuringADeployment = 0,
                                                                @BatchIdOUT = @BatchId OUTPUT'
                                                    ";

        public static string RestoreJobStep = @"
                                                    EXEC msdb.dbo.sp_update_jobstep  
                                                     @job_name =  'Refresh Index Structures' 
                                                    ,@step_id = 2
                                                    ,@step_name = 'Populate Index Structures Queue'
                                                    ,@command = N' 
	                                                       DECLARE @BatchId UNIQUEIDENTIFIER
                                                           
	                                                       TRUNCATE TABLE Utility.RefreshIndexStructuresQueue
	                                                       EXEC Utility.spRefreshIndexStructures_Queue 
			                                                    @OnlineOperations = 1,
			                                                    @IsBeingRunDuringADeployment = 0,
                                                                @BatchIdOUT = @BatchId OUTPUT '
                                                    ";

        public static string DataInPartitionedTable = @" Select * from dbo.PartitioningTestAutomationTable";


        public static string AllPartitionsHaveData = @"
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
                                                        AND  i.name = 'CDX_myDateTime'
                                                        AND p.rows = 0 

                                                        ";

        public static string IndexesAfterPartitioning = @"SELECT IndexName = ix.Name
                                                        FROM sys.indexes ix 
                                                        JOIN sys.tables t  on ix.object_id = t.object_id
                                                        JOIN sys.schemas s  on s.schema_id = t.schema_id
                                                        where 1=1
                                                        AND t.name = 'PartitioningTestAutomationTable'
                                                        AND s.name = 'dbo'";

        public static string RecordsInTheQueue = @"Select * FROM  utility.RefreshIndexStructuresQueue WHERE IsOnlineOperation = 1";

        public static string PartitionStateMetadata = @"
                                                    INSERT INTO Utility.RefreshIndexStructures_PartitionState ( SchemaName ,ParentTableName , PrepTableName, PartitionFromValue ,PartitionToValue ,DataSynchState ,LastUpdateDateTime )
                                                    SELECT SchemaName, ParentTableName, UnPartitionedPrepTableName, PartitionFunctionValue, NextPartitionFunctionValue, 0, GETDATE()
                                                    FROM Utility.fnDataDrivenIndexes_GetPartitionSQL () FN
                                                    WHERE ParentTableName IN ('PartitioningTestAutomationTable')
	                                                    AND NOT EXISTS (SELECT 'True' 
					                                                    FROM Utility.RefreshIndexStructures_PartitionState PS 
					                                                    WHERE PS.SchemaName = FN.SchemaName
						                                                    AND PS.ParentTableName = FN.ParentTableName
						                                                    AND PS.PrepTableName = FN.UnPartitionedPrepTableName)

                                                    DELETE PS
                                                    FROM Utility.RefreshIndexStructures_PartitionState PS
                                                    WHERE NOT EXISTS(	SELECT 'True' 
					                                                    FROM Utility.RefreshIndexStructures_PartitionState PS2
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
                                                    where  j.name = N'Refresh Index Structures'
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
            SELECT 1 FROM Utility.RefreshIndexStructures_PartitionState
            WHERE SchemaName = '{schemaName}'
            AND ParentTableName = '{tableName}'";   
        }
    }
}