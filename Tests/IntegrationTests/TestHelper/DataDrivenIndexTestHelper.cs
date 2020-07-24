using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Threading.Tasks;
using Microsoft.Practices.Unity.Utility;
using NUnit.Framework;
using DOI.Tests.Integration.Models;

namespace DOI.TestHelpers
{
    public class DataDrivenIndexTestHelper
    {
        protected const string DatabaseName = "DOIUnitTests";
        private TestHelper sqlHelper;
        private TempARepository tempARepository;

        public DataDrivenIndexTestHelper(TestHelper sqlHelper)
        {
            this.sqlHelper = sqlHelper;
            this.tempARepository = new TempARepository(sqlHelper);
        }

        public static string OfflineQueueCountSql(string schemaName, string tableName)
        {
            return $@"
            SELECT COUNT(*) 
            FROM DOI.DOI.Queue 
            WHERE DatabaseName = '{DatabaseName}'
                AND SchemaName = '{schemaName}' 
                AND TableName = '{tableName}' 
                AND IsOnlineOperation = 0";
        }

        public List<IndexView> GetIndexViews(string tableName)
        {
            return this.sqlHelper.GetList<IndexView>($"select * FROM DOI.DOI.vwIndexes WHERE DatabaseName = '{DatabaseName}' AND TableName = '{tableName}'");
        }

        public void ExecuteSPQueue(bool onlineOperations, bool isBeingRunDuringADeployment = false)
        {
            var sql = $"DECLARE @BatchId UNIQUEIDENTIFIER " +
                      $"EXEC DOI.DOI.[spQueue]  " +
                        $"@OnlineOperations = {(onlineOperations ? "1" : "0")}" +
                        $",@IsBeingRunDuringADeployment = {(isBeingRunDuringADeployment ? "1" : "0")}" +
                        $",@BatchIdOUT = @BatchId";

            this.sqlHelper.Execute(sql, 120);
        }

        public void ExecuteSPRun(bool onlineOperations, string schemaName = null, string tableName = null)
        {
            var sql = $"EXEC DOI.DOI.[spRun]  " +
                      $"@OnlineOperations = {(onlineOperations ? "1" : "0")}";
            sql += schemaName != null ? $",@SchemaName = '{schemaName}' " : string.Empty;
            sql += tableName != null ? $",@TableName = '{tableName}' " : string.Empty;

            this.sqlHelper.Execute(sql, 0);
        }

        public async Task ExecuteSPRunAsync(bool onlineOperations, string schemaName = null, string tableName = null)
        {
            var sql = $"EXEC DOI.DOI.[spRun]  " +
                      $"@OnlineOperations = {(onlineOperations ? "1" : "0")}";
            sql += schemaName != null ? $",@SchemaName = '{schemaName}' " : string.Empty;
            sql += tableName != null ? $",@TableName = '{tableName}' " : string.Empty;

            await this.sqlHelper.ExecuteAsync(sql, 0, false);
        }

        public void ExecuteSPCreateNewPartitionFunction(string partitionFunctionName)
        {
            this.sqlHelper.Execute($@"EXEC DOI.DOI.[spRefreshStorageContainers_PartitionFunctions] 
                                        @DatabaseName = '{DatabaseName}',
                                        @PartitionFunctionName = '{partitionFunctionName}'");

            this.sqlHelper.Execute(@"EXEC DOI.DOI.spRefreshMetadata_System_PartitionFunctionsAndSchemes");
            this.sqlHelper.Execute($@"EXEC DOI.DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData");
        }

        public void ExecuteSPCreateNewPartitionScheme(string partitionFunctionName)
        {
            this.sqlHelper.Execute($@"EXEC DOI.DOI.[spRefreshStorageContainers_PartitionSchemes] 
                                        @DatabaseName = '{DatabaseName}',
                                        @PartitionFunctionName = '{partitionFunctionName}'");

            this.sqlHelper.Execute(@"EXEC DOI.DOI.[spRefreshMetadata_System_PartitionFunctionsAndSchemes]");
        }

        public List<PartitionFunctionBoundary> GetExistingPartitionFunctionBoundaries(string partitionFunctionName)
        {
            return this.sqlHelper.GetList<PartitionFunctionBoundary>($@"
                USE {DatabaseName}
               	SELECT name, type, boundary_value_on_right AS BoundaryValueOnRight, boundary_id AS BoundaryId, value
            	FROM sys.partition_functions pf 
            		INNER JOIN sys.partition_range_values prv ON prv.function_id = pf.function_id
	            WHERE pf.name = '{partitionFunctionName}'");
        }

        public List<PartitionSchemeFilegroup> GetExistingPartitionSchemeFilegroups(string partitionFunctionName)
        {
            return this.sqlHelper.GetList<PartitionSchemeFilegroup>($@"
                USE {DatabaseName}
            SELECT destination_id AS DestinationFilegroupId, ps.name AS PartitionSchemeName, f.type AS DataSpaceType, f.name AS FilegroupName
            FROM SYS.partition_schemes ps
                INNER JOIN sys.destination_data_spaces dds on dds.partition_scheme_id = ps.data_space_id
                INNER JOIN sys.filegroups f on dds.data_space_id = f.data_space_id
                INNER JOIN sys.partition_functions pf on pf.function_id = ps.function_id
            WHERE pf.name = '{partitionFunctionName}'");
        }

        public List<PrepTable> GetPrepTableFunctionDuplicates(string partitionFunctionName)
        {
            if (partitionFunctionName == null)
            {
                return this.sqlHelper.GetList<PrepTable>($@"
               	SELECT PrepTableName
            	FROM DOI.DOI.vwTables_PrepTables)
                WHERE DatabaseName = '{DatabaseName}'
                GROUP BY PrepTableName
            	HAVING COUNT(*) > 1");
            }
            else 
            {
                return this.sqlHelper.GetList<PrepTable>($@"
               	SELECT PrepTableName
            	FROM DOI.DOI.vwTables_PrepTables
                WHERE DatabaseName = '{DatabaseName}'
                    AND PartitionFunctionName = '{partitionFunctionName}'
                GROUP BY PrepTableName
            	HAVING COUNT(*) > 1");
            }
        }

        public List<PrepTable> GetPartitionStateFunctionDuplicates(string tableName)
        {
            var whereStatement = string.Empty;

            if (tableName != null)
            {
                whereStatement = $"WHERE FN.ParentTableName = '{tableName}'";
            }

            return this.sqlHelper.GetList<PrepTable>($@"
               	    SELECT FN.PartitionFunctionValue, COUNT(*)
                    FROM DOI.DOI.fnDataDrivenIndexes_GetPartitionSQL () FN
                    {whereStatement}
                    GROUP BY FN.PartitionFunctionValue
                    HAVING COUNT(*) > 1");
        }

        public List<PartitionFunctionBoundary> SetupExpectedPartitionFunctionBoundaries(string partitionFunctionName)
        {
            var expectedMonthlyPartitionFunctionBoundaries = new List<PartitionFunctionBoundary>();

            List<List<Pair<string, object>>> rows = this.sqlHelper.ExecuteQuery(new SqlCommand($@"
                SELECT InitialDate, NumOfTotalPartitionFunctionIntervals
                FROM DOI.DOI.PartitionFunctions 
                WHERE DatabaseName = '{DatabaseName}'
                    AND PartitionFunctionName = '{partitionFunctionName}'"));

            var initialDate = rows[0].Find(x => x.First == "InitialDate").Second.ObjectToDateTime();
            var boundaryDate = initialDate;
            var totalPartitionFunctionIntervals = rows[0].Find(x => x.First == "NumOfTotalPartitionFunctionIntervals").Second.ObjectToInteger();

            for (int i = 1; i <= totalPartitionFunctionIntervals; i++)
            {
                expectedMonthlyPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                {
                        Name = partitionFunctionName,
                        Type = "R",
                        BoundaryValueOnRight = true,
                        BoundaryId = i,
                        Value = boundaryDate
                });

                boundaryDate = boundaryDate.AddMonths(1);
            }

            return expectedMonthlyPartitionFunctionBoundaries;
        }

        public List<PartitionSchemeFilegroup> SetupExpectedPartitionSchemeFilegroups(string partitionFunctionName)
        {
            var expectedMonthlyPartitionSchemeFilegroups = new List<PartitionSchemeFilegroup>();

            List<List<Pair<string, object>>> rows = this.sqlHelper.ExecuteQuery(new SqlCommand($@"
                SELECT InitialDate, NumOfTotalPartitionSchemeIntervals, PartitionSchemeName
                FROM DOI.DOI.PartitionFunctions 
                WHERE DatabaseName = '{DatabaseName}'
                    AND PartitionFunctionName = '{partitionFunctionName}'"));

            var initialDate = rows[0].Find(x => x.First == "InitialDate").Second.ObjectToDateTime();
            var totalPartitionSchemeIntervals = rows[0].Find(x => x.First == "NumOfTotalPartitionSchemeIntervals").Second.ObjectToInteger();
            var partitionSchemeName = rows[0].Find(x => x.First == "PartitionSchemeName").Second.ToString();
            var boundaryDate = initialDate;

            for (int i = 1; i <= totalPartitionSchemeIntervals; i++)
            {
                string filegroupName;

                if (i == 1)
                {
                    filegroupName = $"{DatabaseName}_Historical";
                }
                else
                {
                    filegroupName = $"{DatabaseName}_" + boundaryDate.Year.ToString() + boundaryDate.Month.ToString("#00");
                }

                expectedMonthlyPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                {
                    DestinationFilegroupId = i,
                    PartitionSchemeName = partitionSchemeName,
                    DataSpaceType = "FG",
                    FilegroupName = filegroupName
                });

                if (i > 1)
                {
                    boundaryDate = boundaryDate.AddMonths(1);
                }
            }

            return expectedMonthlyPartitionSchemeFilegroups;
        }

        public void ExecuteSPAddFuturePartitions(string partitionFunctionName, int commandTimeoutSec = 30)
        {
            var sql = $@"EXEC DOI.DOI.[spRefreshStorageContainers_AddNewPartition] 
                            @DatabaseName = '{DatabaseName}',
                            @PartitionFunctionName = '{partitionFunctionName}'";

            this.sqlHelper.Execute(sql, commandTimeoutSec);
        }

        public List<MetaDataTable> GetTablesInMetaData()
        {
            return this.sqlHelper.GetList<MetaDataTable>($"select * FROM DOI.DOI.Tables WHERE DatabaseName = '{DatabaseName}'");
        }

        public List<MetaDataTable> GetTablesReadytoQueue()
        {
            return this.sqlHelper.GetList<MetaDataTable>($"select * FROM DOI.DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND ReadyToQueue = 1 ");
        }

        public List<LogTableRow> GetErrorsFromLogTables(Guid batchId)
        {
            return this.sqlHelper.GetList<LogTableRow>($"select * FROM DOI.DOI.Log WHERE DatabaseName = '{DatabaseName}' AND BatchId = '{batchId}");
        }

        public List<Index> GetExistingIndexes()
        {
            return this.sqlHelper.GetList<Index>($@"
                USE {DatabaseName}
                SELECT S.NAME AS SchemaName, T.NAME AS TableName, I.NAME AS IndexName
	            FROM SYS.INDEXES I
		        INNER JOIN SYS.TABLES T ON T.object_id = I.object_id
		        INNER JOIN SYS.SCHEMAS S ON S.schema_id = T.schema_id
                WHERE I.type != 0 "); // excludes heap indexes.
        }

        public List<Index> GetIndexInMetaData()
        {
            return this.sqlHelper.GetList<Index>($@"
                SELECT SchemaName, TableName, IndexName
                FROM DOI.DOI.IndexesColumnStore 
                WHERE DatabaseName = '{DatabaseName}'
                UNION 
                SELECT UIRS.SchemaName, UIRS.TableName, IndexName
                FROM DOI.DOI.IndexesRowStore UIRS
				    INNER JOIN DOI.DOI.Tables UT ON UIRS.DatabaseName = UT.DatabaseName
                        AND UIRS.SchemaName = UT.SchemaName
				        AND UIRS.TableName = UT.TableName
				WHERE DatabaseName = '{DatabaseName}'
                    AND UT.ReadyToQueue =1");
        }

        public List<Statistics> GetActualStatisticsDetails(string statisticsName)
        {
            return this.sqlHelper.GetList<Statistics>($@"
                USE {DatabaseName}
                SELECT  s.name AS SchemaName, 
                        t.name AS TableName, 
                        st.name AS StatisticsName, 
                        STUFF(StatsColumn.ColumnList, LEN(StatsColumn.ColumnList), 1, SPACE(0)) AS StatisticsColumnList, 
                        CAST((((sp.rows_sampled * 1.00)/sp.rows) * 100) AS DECIMAL(5,2)) AS SampleSizePct,
                        CASE WHEN st.filter_definition IS NULL THEN 0 ELSE 1 END AS IsFiltered, 
                        st.filter_definition AS FilterPredicate,
                        st.is_incremental AS IsIncremental,
                        st.no_recompute AS NoRecompute 
                FROM sys.stats st
                    INNER JOIN sys.tables t ON t.object_id = st.object_id
                    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
                    CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) sp
                    CROSS APPLY (   SELECT c.name + ','
                                    FROM SYS.stats_columns sc 
                                        INNER JOIN sys.columns c ON c.object_id = sc.object_id
                                            AND c.column_id = sc.column_id
                                    WHERE sc.object_id = st.object_id 
                                        AND sc.stats_id = st.stats_id
                                    FOR XML PATH('')) StatsColumn(ColumnList)
                WHERE st.name = '{statisticsName}'");
        }

        public List<Statistics> GetExpectedStatisticsDetails(string statisticsName)
        {
            return this.sqlHelper.GetList<Statistics>($@"
                SELECT  st.SchemaName, 
                        st.TableName, 
                        st.StatisticsName, 
                        st.StatisticsColumnList, 
                        st.SampleSizePct,
                        st.IsFiltered, 
                        st.FilterPredicate,
                        st.IsIncremental,
                        st.NoRecompute 
                FROM DOI.DOI.[Statistics] st
                WHERE DatabaseName = '{DatabaseName}'
                    AND st.StatisticsName = '{statisticsName}'");
        }

        public List<ForeignKey> GetForeignKeys(string parentTableName)
        {
            return this.sqlHelper.GetList<ForeignKey>($"select * FROM DOI.DOI.ForeignKeys WHERE DatabaseName = '{DatabaseName}' AND ReferencedTableName = '{parentTableName}'");
        }

        public List<string> GetExistingForeignKeyNames(string parentTableName)
        {
            return this.sqlHelper.ExecuteList<string>($"SELECT name as Name FROM SYS.foreign_keys fk WHERE DatabaseName = '{DatabaseName}' AND OBJECT_NAME(fk.referenced_object_id) = '{parentTableName}'");
        }

        public void CreateIndex(string indexName)
        {
            switch (indexName)
            {
                case "PK_TempA":
                    this.CreatePKTempA();
                    break;
                case "CDX_TempA":
                    this.CreateCDXTempA();
                    break;
                case "NIDX_TempA_Report":
                    this.CreateNIDXTempAReport();
                    break;
                case "NIDX_TempA_Report2":
                    this.CreateNIDXTempAReport2();
                    break;
                case "PK_TempB":
                    this.CreatePKTempB();
                    break;
                case "NCCI_TempA_Report":
                    this.CreateNCCITempAReport();
                    break;
                case "CCI_TempB_Report":
                    this.CreateCCITempBReport();
                    break;
            }
        }

        public void CreateForeignKeys()
        {
            this.sqlHelper.Execute($@"INSERT INTO DOI.[DOI].[ForeignKeys]    (DatabaseName, [ParentSchemaName]	,[ParentTableName]	,[ParentColumnList_Desired]	,[ReferencedSchemaName]	,[ReferencedTableName]	,[ReferencedColumnList_Desired])
                                                                 VALUES ('{DatabaseName}', 'dbo'				,'TempB'			,'TempAId'			,'dbo'					,'TempA'				,'TempAId')");
            this.sqlHelper.Execute($@"EXEC DOI.DOI.spForeignKeysAdd 
                                       @DatabaseName = '{DatabaseName}',
                                       @ReferencedSchemaName = 'dbo'
                                      ,@ReferencedTableName = 'TempA'
                                      ,@ParentSchemaName = 'dbo'
                                      ,@ParentTableName = 'TempB'");
        }

        public void AddRowsToTempA(int numberOfRows)
        {
            var numberOfRowsInserted = 0;

            do
            {
                var rows = new List<TempARow>();

                for (var i = 0; i < 1000; i++)
                {
                    rows.Add(new TempARow());
                    numberOfRowsInserted++;

                    if (numberOfRowsInserted >= numberOfRows)
                    {
                        break;
                    }
                }

                this.tempARepository.InsertRows(rows);
            }
            while (numberOfRowsInserted < numberOfRows);
        }

        public void SeedDataAndDefrag(int numberOfRowsToInsertPerLoop)
        {
            var pageSize = this.sqlHelper.ExecuteScalar<int>($"SELECT CAST(SettingValue AS INT) FROM DOI.DOI.DOISettings WHERE DatabaseName = '{DatabaseName}' AND SettingName = 'MinNumPagesForIndexDefrag'");
            var indexRows = new List<IndexView>();
            var watch = Stopwatch.StartNew();

            // Seed data to get page size over specified amount and defrag.
            do
            {
                this.AddRowsToTempA(numberOfRowsToInsertPerLoop);

                indexRows = this.GetIndexViews("TempA");

                if (indexRows.Exists(i => i.TotalPages > pageSize))
                {
                    if (indexRows.Exists(j => j.IndexFragmentation > 5 && j.IndexFragmentation < 30))
                    {
                        break;
                    }
                }

                Assert.Greater(180000, watch.ElapsedMilliseconds, "Test timed out.");
            }
            while (true);
        }

        private void CreatePKTempA()
        {
            this.sqlHelper.Execute($@"USE {DatabaseName} ALTER TABLE dbo.TempA ADD CONSTRAINT PK_TempA PRIMARY KEY NONCLUSTERED (
                                        TempAId ASC
                                    ) WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)");

            this.sqlHelper.Execute($@"INSERT INTO DOI.DOI.IndexesRowStore    (	DatabaseName, SchemaName	,TableName	,IndexName		,IsUnique_Desired	,IsPrimaryKey_Desired	, IsUniqueConstraint_Desired, IsClustered_Desired	,KeyColumnList_Desired	    ,IncludedColumnList_Desired	,IsFiltered_Desired ,FilterPredicate_Desired	,[Fillfactor_Desired]	    ,OptionPadIndex_Desired ,OptionStatisticsNoRecompute_Desired	,OptionStatisticsIncremental_Desired	,OptionIgnoreDupKey_Desired ,OptionResumable_Desired	,OptionMaxDuration_Desired	,OptionAllowRowLocks_Desired	,OptionAllowPageLocks_Desired	,OptionDataCompression_Desired	, Storage_Desired	, PartitionColumn_Desired	)
                                                                VALUES  (	'{DatabaseName}', N'dbo'		, N'TempA'	, N'PK_TempA'	, 1			        , 1				        , 0					        , 0				        , N'TempAId ASC'            , NULL				        , 0			        , NULL				        , 90				        , 1				        , 0								        , 0								        , 0					        , DEFAULT			        , 0					        , 1						        , 1						        , 'NONE'				        , 'PRIMARY'		    , NULL				)");
        }

        private void CreateCDXTempA()
        {
            this.sqlHelper.Execute($@"USE {DatabaseName} CREATE CLUSTERED INDEX [CDX_TempA] ON dbo.TempA
                                    (
	                                    TempAId ASC,
	                                    TransactionUtcDt ASC
                                    )WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)");

            this.sqlHelper.Execute($@"INSERT INTO DOI.DOI.IndexesRowStore    (	DatabaseName, SchemaName	,TableName	,IndexName		,IsUnique_Desired	,IsPrimaryKey_Desired	, IsUniqueConstraint_Desired, IsClustered_Desired	,KeyColumnList_Desired	                ,IncludedColumnList_Desired	,IsFiltered_Desired ,FilterPredicate_Desired	,[Fillfactor_Desired]	    ,OptionPadIndex_Desired ,OptionStatisticsNoRecompute_Desired	,OptionStatisticsIncremental_Desired	,OptionIgnoreDupKey_Desired ,OptionResumable_Desired	,OptionMaxDuration_Desired	,OptionAllowRowLocks_Desired	,OptionAllowPageLocks_Desired	,OptionDataCompression_Desired	, Storage_Desired	, PartitionColumn_Desired	)
                                                                VALUES   (	'{DatabaseName}', N'dbo'		, N'TempA'	, N'CDX_TempA'	, 0			        , 0				        , 0					        , 1				        , N'TempAId ASC,TransactionUtcDt ASC'	, NULL				        , 0			        , NULL				        , 90			            , DEFAULT		        , DEFAULT						        , DEFAULT						        , DEFAULT			        , DEFAULT			        , DEFAULT			        , DEFAULT				        , DEFAULT				        , 'NONE'				        , 'PRIMARY'		    , NULL				)");
        }

        private void CreateNIDXTempAReport()
        {
            this.sqlHelper.Execute($@"USE {DatabaseName} CREATE NONCLUSTERED INDEX [NIDX_TempA_Report] ON dbo.TempA
                                    (
	                                    TransactionUtcDt ASC
                                    ) INCLUDE(TextCol) WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)");

            this.sqlHelper.Execute($@"INSERT INTO DOI.DOI.IndexesRowStore    (	DatabaseName, SchemaName	,TableName	,IndexName		        ,IsUnique_Desired	,IsPrimaryKey_Desired	, IsUniqueConstraint_Desired, IsClustered_Desired	,KeyColumnList_Desired	    ,IncludedColumnList_Desired	,IsFiltered_Desired ,FilterPredicate_Desired	,[Fillfactor_Desired]	    ,OptionPadIndex_Desired ,OptionStatisticsNoRecompute_Desired	,OptionStatisticsIncremental_Desired	,OptionIgnoreDupKey_Desired ,OptionResumable_Desired	,OptionMaxDuration_Desired	,OptionAllowRowLocks_Desired	,OptionAllowPageLocks_Desired	,OptionDataCompression_Desired	, Storage_Desired	, PartitionColumn_Desired	)
                                                                VALUES   (	'{DatabaseName}', N'dbo'		, N'TempA'	, N'NIDX_TempA_Report'	, 0			        , 0				        , 0					        , 0				        , N'TransactionUtcDt ASC'	,N'TextCol'			        , 0			        , NULL				        , 80			            , DEFAULT		        , DEFAULT						        , DEFAULT						        , DEFAULT			        , DEFAULT			        , DEFAULT			        , DEFAULT				        , DEFAULT				        , 'NONE'				        , 'PRIMARY'		    , NULL				)");
        }

        private void CreateNIDXTempAReport2()
        {
            this.sqlHelper.Execute($@"USE {DatabaseName} CREATE NONCLUSTERED INDEX [NIDX_TempA_Report2] ON dbo.TempA
                                    (
	                                    TransactionUtcDt ASC
                                    )WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)");

            this.sqlHelper.Execute($@"INSERT INTO DOI.DOI.IndexesRowStore    (	DatabaseName, SchemaName	,TableName	,IndexName		        ,IsUnique_Desired	,IsPrimaryKey_Desired	, IsUniqueConstraint_Desired, IsClustered_Desired	,KeyColumnList_Desired	    ,IncludedColumnList_Desired	,IsFiltered_Desired ,FilterPredicate_Desired	,[Fillfactor_Desired]	    ,OptionPadIndex_Desired ,OptionStatisticsNoRecompute_Desired	,OptionStatisticsIncremental_Desired	,OptionIgnoreDupKey_Desired ,OptionResumable_Desired	,OptionMaxDuration_Desired	,OptionAllowRowLocks_Desired	,OptionAllowPageLocks_Desired	,OptionDataCompression_Desired	, Storage_Desired	, PartitionColumn_Desired	)
                                                                VALUES	  (	'{DatabaseName}', N'dbo'		, N'TempA'	, N'NIDX_TempA_Report2'	, 0			        , 0				        , 0					        , 0				        , N'TransactionUtcDt ASC'	, NULL				        , 0			        , NULL				        , 90			            , DEFAULT		        , DEFAULT						        , DEFAULT						        , DEFAULT			        , DEFAULT			        , DEFAULT			        , DEFAULT				        , DEFAULT				        , 'NONE'				        , 'PRIMARY'		    , NULL				)");
        }

        private void CreatePKTempB()
        {
            this.sqlHelper.Execute($@"USE {DatabaseName} ALTER TABLE dbo.TempB ADD CONSTRAINT PK_TempB PRIMARY KEY NONCLUSTERED (
                                        TempBId ASC
                                    ) WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)");

            this.sqlHelper.Execute($@"INSERT INTO DOI.DOI.IndexesRowStore    (	DatabaseName, SchemaName	,TableName	,IndexName		,IsUnique_Desired	,IsPrimaryKey_Desired	, IsUniqueConstraint_Desired, IsClustered_Desired	,KeyColumnList_Desired	    ,IncludedColumnList_Desired	,IsFiltered_Desired ,FilterPredicate_Desired	,[Fillfactor_Desired]	    ,OptionPadIndex_Desired ,OptionStatisticsNoRecompute_Desired	,OptionStatisticsIncremental_Desired	,OptionIgnoreDupKey_Desired ,OptionResumable_Desired	,OptionMaxDuration_Desired	,OptionAllowRowLocks_Desired	,OptionAllowPageLocks_Desired	,OptionDataCompression_Desired	, Storage_Desired	, PartitionColumn_Desired	)
                                                                VALUES	  (	'{DatabaseName}', N'dbo'		, N'TempB'	, N'PK_TempB'	, 1			        , 1				        , 0					        , 0				        , N'TempBId ASC'            , NULL				        , 0			        , NULL				        , 90			            , DEFAULT		        , DEFAULT						        , DEFAULT						        , DEFAULT			        , DEFAULT			        , DEFAULT			        , DEFAULT				        , DEFAULT				        , 'NONE'				        , 'PRIMARY'		    , NULL				)");
        }

        private void CreateNCCITempAReport()
        {
            this.sqlHelper.Execute($@"USE {DatabaseName} CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_TempA_Report] ON dbo.TempA
                                    (
	                                    TransactionUtcDt
                                    )WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)");

            this.sqlHelper.Execute($@"INSERT DOI.DOI.[IndexesColumnStore]  (DatabaseName, [SchemaName]	, [TableName]   , [IndexName]			, [IsClustered_Desired]	, [ColumnList_Desired]			, [IsFiltered_Desired]	, [FilterPredicate_Desired]	, [OptionDataCompression_Desired]	, [OptionDataCompressionDelay_Desired]	, Storage_Desired    , PartitionColumn_Desired		) 
                                                                    VALUES	('{DatabaseName}', N'dbo'			, N'TempA'	    , N'NCCI_TempA_Report'	, 0				        , N'TransactionUtcDt'	        , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							        , 'PRIMARY'	         , NULL					)");
        }

        private void CreateCCITempBReport()
        {
            this.sqlHelper.Execute($@"USE {DatabaseName} CREATE CLUSTERED COLUMNSTORE INDEX CCI_TempB_Report     ON dbo.TempB          
                                    WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, MAXDOP = 0, DATA_COMPRESSION = COLUMNSTORE) ");

            this.sqlHelper.Execute($@"INSERT DOI.DOI.[IndexesColumnStore]  (DatabaseName, [SchemaName]	, [TableName]   , [IndexName]			, [IsClustered_Desired]	, [ColumnList_Desired]			, [IsFiltered_Desired]	, [FilterPredicate_Desired]	, [OptionDataCompression_Desired]	, [OptionDataCompressionDelay_Desired]	, Storage_Desired    , PartitionColumn_Desired		) 
                                                                 VALUES	('{DatabaseName}', N'dbo'		, N'TempB'		, N'CCI_TempB_Report'	, 1				, NULL					, 0				, NULL				, N'COLUMNSTORE'			, 0							, 'PRIMARY'	    , NULL					)");
        }
    }
}
