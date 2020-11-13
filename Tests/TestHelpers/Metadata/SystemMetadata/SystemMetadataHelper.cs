using System;
using System.Data.SqlClient;
using DOI.Tests.Integration.Models;
using Simple.Data.Ado.Schema;


namespace DOI.Tests.TestHelpers.Metadata.SystemMetadata
{
    public class SystemMetadataHelper
    {
        private SqlHelper sqlHelper = new SqlHelper();

        #region Databases

        public const string DatabaseName = "DOIUnitTests";
        public static string RefreshMetadata_SysDatabasesSql = $@"EXEC DOI.spRefreshMetadata_System_SysDatabases @DatabaseName = '{DatabaseName}'";

        #endregion

        #region FileGroups

        public const string FilegroupName = "Test1FG1";
        public const string Filegroup2Name = "Test1FG2";
        public static string CreateFilegroupSql = $@"ALTER DATABASE {DatabaseName} ADD FILEGROUP {FilegroupName};";
        public static string CreateFilegroup2Sql = $@"ALTER DATABASE {DatabaseName} ADD FILEGROUP {Filegroup2Name};";


        public static string DropFilegroupSql = $@"ALTER DATABASE {DatabaseName} REMOVE FILEGROUP {FilegroupName};";
        public static string DropFilegroup2Sql = $@"ALTER DATABASE {DatabaseName} REMOVE FILEGROUP {Filegroup2Name};";


        public static string RefreshMetadata_SysFilegroupsSql = $"EXEC DOI.spRefreshMetadata_System_SysFilegroups @DatabaseName = '{DatabaseName}'";
        public static string RefreshMetadata_SysDataSpacesSql = $"EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'";
        public static string RefreshMetadata_SysDestinationDataSpacesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysFilegroups @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionSchemes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces @DatabaseName = '{DatabaseName}'";
        

        #endregion
        #region DatabaseFiles

        public static string DatabaseFileName = "testDBFileName";
        public static string CreateDatabaseFileSql = $@"
        ALTER DATABASE {DatabaseName}
            ADD FILE
            (
                NAME = {DatabaseFileName},
                FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\{DatabaseFileName}.ndf',
                SIZE = 5MB,
                MAXSIZE = 100MB,
                FILEGROWTH = 5MB
            )";

        public static string DropDatabaseFileSql = $@"ALTER DATABASE {DatabaseName} REMOVE FILE {DatabaseFileName}";

        public static string RefreshMetadata_SysDatabaseFilesSql = $"EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'";
        public static string RefreshMetadata_SysMasterFilesSql = $"EXEC DOI.spRefreshMetadata_System_SysMasterFiles @DatabaseName = '{DatabaseName}'";
        public static string RefreshMetadata_SysDmOsVolumeStatsSql = $@"
        EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}' 
        EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats @DatabaseName = '{DatabaseName}'";

        #endregion
        #region PartitionFunctions

        public const string PartitionFunctionName = "pfTests";

        public static string CreatePartitionFunctionSql = $"CREATE PARTITION FUNCTION [{PartitionFunctionName}](datetime2(7)) AS RANGE RIGHT FOR VALUES (N'2016-01-01T00:00:00.000')";

        public static string DropPartitionFunctionSql = $"DROP PARTITION FUNCTION {PartitionFunctionName}";

        public static string RefreshMetadata_SysPartitionFunctionsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysPartitionRangeValuesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionRangeValues @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData @DatabaseName = '{DatabaseName}'";

        public static string CreatePartitionFunctionMetadataSql = $@"
            INSERT INTO DOI.PartitionFunctions( DatabaseName    ,PartitionFunctionName      ,PartitionFunctionDataType  ,BoundaryInterval   ,NumOfFutureIntervals   ,InitialDate    ,UsesSlidingWindow  ,SlidingWindowSize  ,IsDeprecated   ,PartitionSchemeName    ,NumOfCharsInSuffix ,LastBoundaryDate   ,NumOfTotalPartitionFunctionIntervals   ,NumOfTotalPartitionSchemeIntervals ,MinValueOfDataType)
            VALUES(                             '{DatabaseName}', '{PartitionFunctionName}' ,'DATETIME2'                ,'Yearly'           ,1                      ,'2016-01-01'   ,0                  ,NULL               ,0              ,'{PartitionSchemeName}',0                  ,N'2016-01-01'      ,2                                      ,3                                  ,'0001-01-01')";

        public static string GetPartitionsFrom_vwPartitionFunctionPartitions = $@"
            SELECT * FROM DOI.vwPartitionFunctionPartitions WHERE DatabaseName = '{DatabaseName}' AND PartitionFunctionName = '{PartitionFunctionName}'";
        

        #endregion
        #region PartitionSchemes

        public const string PartitionSchemeName = "psTests";

        public static string CreatePartitionSchemeSql = $"CREATE PARTITION SCHEME [{PartitionSchemeName}] AS PARTITION [{PartitionFunctionName}] TO ([{FilegroupName}], [{Filegroup2Name}])";

        public static string DropPartitionSchemeSql = $"DROP PARTITION SCHEME {PartitionSchemeName}";

        public static string RefreshMetadata_SysPartitionSchemesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysFilegroups @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionSchemes @DatabaseName = '{DatabaseName}'";

        #endregion


        #region Schemas

        public static string CreateSchemaSql = "CREATE SCHEMA TEST AUTHORIZATION DBO";
        public static string DropSchemaSql = "DROP SCHEMA IF EXISTS TEST";
        public static string RefreshMetadata_SysSchemasSql = $"EXEC DOI.spRefreshMetadata_System_SysSchemas @DatabaseName = {DatabaseName}";
        #endregion

        #region Tables

        public const string TableName = "TempA";
        public const string ChildTableName = "TempB";
        public static string DeleteTableSql = $"DELETE FROM dbo.{TableName}";

        public static string InsertOneRowIntoTableSql = $@"INSERT INTO dbo.{TableName}(TempAId, TransactionUtcDt, IncludedColumn, TextCol) VALUES('{Guid.Parse("0525CED4-4F7B-4212-B511-44D13C129DA9")}', SYSDATETIME(), 'BLA', 'BLA')";

        public static string CreateTableSql = $@"
        CREATE TABLE dbo.{TableName}(
            TempAId uniqueidentifier NOT NULL PRIMARY KEY NONCLUSTERED,
            TransactionUtcDt datetime2(7) NOT NULL,
            IncludedColumn VARCHAR(50) NULL,
            TextCol VARCHAR(8000) NULL 
        )";

        public static string CreateChildTableSql = $@"
        CREATE TABLE dbo.{ChildTableName}(
	        TempBId uniqueidentifier NOT NULL,
	        TempAId uniqueidentifier NOT NULL,
	        TransactionUtcDt datetime2(7) NOT NULL,
        )";

        public static string CreateTableMetadataSql = $@"
        DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}'
        INSERT INTO DOI.Tables  (DatabaseName       , SchemaName    ,TableName					,PartitionColumn			,Storage_Desired					, IntendToPartition	,  ReadyToQueue) 
        VALUES                  ('{DatabaseName}'   , 'dbo'	        ,'{TableName}'				,NULL						, 'PRIMARY'							, 0					,  1)";

        public static string CreateChildTableMetadataSql = $@"
        DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{ChildTableName}'
        INSERT INTO DOI.Tables  (DatabaseName       , SchemaName    ,TableName					,PartitionColumn			,Storage_Desired					, IntendToPartition	,  ReadyToQueue) 
        VALUES                  ('{DatabaseName}'   , 'dbo'	        ,'{ChildTableName}'			,NULL						, 'PRIMARY'							, 0					,  1)";

        public static string DropTableSql = $"DROP TABLE IF EXISTS dbo.{TableName}";
        public static string DropTableMetadataSql = $@"DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}'";
        public static string DropChildTableSql = $"DROP TABLE IF EXISTS dbo.{ChildTableName}";
        public static string DropChildTableMetadataSql = $@"DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{ChildTableName}'";



        public static string RefreshMetadata_SysTablesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_Tables_UpdateData @DatabaseName = '{DatabaseName}'";

        #endregion

        #region SysCheckConstraints

        public static string CheckConstraintName = "Chk_TestCheckConstraint";

        public static string CreateCheckConstraintSql = $@"
            ALTER TABLE {TableName} 
                ADD CONSTRAINT {CheckConstraintName}
                    CHECK (ISNUMERIC(TempAId) = 1)";

        public static string DropCheckConstraintSql = $@"ALTER TABLE {TableName} DROP CONSTRAINT {CheckConstraintName}";

        public static string RefreshMetadata_SysCheckConstraintsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysCheckConstraints @DatabaseName = '{DatabaseName}'";

        #endregion

        #region SysDefaultConstraints

        public static string DefaultConstraintName = "Def_TestDefaultConstraint";

        public static string CreateDefaultConstraintSql = $@"
            ALTER TABLE {TableName} 
                ADD CONSTRAINT {DefaultConstraintName}
                    DEFAULT SYSDATETIME() FOR TransactionUtcDt";

        public static string DropDefaultConstraintSql = $@"ALTER TABLE {TableName} DROP CONSTRAINT {DefaultConstraintName}";

        public static string RefreshMetadata_SysDefaultConstraintsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDefaultConstraints @DatabaseName = '{DatabaseName}'";

        #endregion

        #region SysTriggers

        public static string TriggerName = $"tr{TableName}";

        public static string CreateTriggersql = $@"
            CREATE TRIGGER dbo.{TriggerName} ON {TableName} FOR INSERT AS SELECT SYSDATETIME()";

        public static string DropTriggersql = $@"DROP TRIGGER dbo.{TriggerName}";

        public static string RefreshMetadata_SysTriggersSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysTriggers @DatabaseName = '{DatabaseName}'";

        #endregion

        #region ForeignKeys

        public static string ForeignKeyName = "FK_TempB_TempAId";

        public static string CreateForeignKeySql = $@"
            ALTER TABLE dbo.{ChildTableName} 
                ADD CONSTRAINT {ForeignKeyName}
                    FOREIGN KEY (TempAId) REFERENCES dbo.{TableName}(TempAId)";

        public static string CreateForeignKeyMetadataSql = $@"

DELETE DOI.ForeignKeys WHERE DatabaseName = '{DatabaseName}' AND FKName = '{ForeignKeyName}'

INSERT [DOI].[ForeignKeys] 
        ([DatabaseName]       , [ParentSchemaName]  , [ParentTableName]     , [ParentColumnList_Desired]    , [ReferencedSchemaName], [ReferencedTableName] , [ReferencedColumnList_Desired], [FKName]) 
VALUES	 (N'{DatabaseName}'   ,N'dbo'               , N'{ChildTableName}'   , N'TempAId'					, N'dbo'    	        , N'{TableName}'		, N'TempAId'                    , N'{ForeignKeyName}')
";

        public static string DropForeignKeySql = $@"ALTER TABLE dbo.{ChildTableName} DROP CONSTRAINT {ForeignKeyName}";

        public static string RefreshMetadata_SysForeignKeysSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysForeignKeys @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysForeignKeyColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysForeignKeys_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_ForeignKeys_UpdateData @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysForeignKeyColumnsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysForeignKeys @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysForeignKeyColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysForeignKeys_UpdateData @DatabaseName = '{DatabaseName}'";

        #endregion

        #region Indexes
        public const string IndexName = "CDX_TempA_TempAId";
        public const string IndexName_ColumnStore = "NCCI_TempA";
        
        public static string CreateIndexSql = $"CREATE UNIQUE CLUSTERED INDEX {IndexName} ON dbo.{TableName}(TempAId) WITH (FILLFACTOR = 100, PAD_INDEX = ON, DATA_COMPRESSION = PAGE) ON [PRIMARY] ";

        public static string CreateIndexMetadataSql = $@"
            INSERT INTO DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, 
                                            IsFiltered_Desired, FilterPredicate_Desired, Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, 
                                            OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, Storage_Desired, StorageType_Desired, 
                                            PartitionFunction_Desired, PartitionColumn_Desired)
            VALUES (N'{DatabaseName}', N'dbo', N'{TableName}', N'{IndexName}', 1, 0, 0, 1, 'TempAId ASC', NULL,  
                    0, NULL, 100, 1, 0, 0, 0, 
                    0, 0, 1, 1, N'PAGE', 'PRIMARY', N'ROWS_FILEGROUP', 
                    NULL, NULL)";

        public static string DropIndexSql = $"DROP INDEX IF EXISTS {IndexName} ON dbo.{TableName}";

        public static string CreateColumnStoreIndexSql = $"CREATE NONCLUSTERED COLUMNSTORE INDEX {IndexName_ColumnStore} ON dbo.{TableName}(TransactionUtcDt) WITH (DATA_COMPRESSION = COLUMNSTORE)";

        public static string CreateColumnStoreIndexMetadataSql = $@"
            INSERT INTO DOI.IndexesColumnStore
                (DatabaseName, SchemaName, TableName, IndexName, IsClustered_Desired, ColumnList_Desired, IsFiltered_Desired, FilterPredicate_Desired,
                 OptionDataCompression_Desired, OptionDataCompressionDelay_Desired, Storage_Desired, StorageType_Desired, PartitionFunction_Desired,
                 PartitionColumn_Desired)
            VALUES(N'{DatabaseName}', N'dbo', N'{TableName}', N'{IndexName_ColumnStore}', 0, N'TransactionUtcDt ASC', 0, NULL, 
                'COLUMNSTORE', 0, N'PRIMARY', N'ROWS_FILEGROUP', NULL, 
                NULL)";

        public static string DropColumnStoreIndex = $"DROP INDEX IF EXISTS {IndexName_ColumnStore} ON dbo.{TableName}";

        public static string RefreshMetadata_SysIndexesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysSchemas @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStats @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysAllocationUnits @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_IndexesRowStore_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_UpdateData @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysIndexColumnsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexColumns @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysIndexPhysicalStatsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexPhysicalStats @DatabaseName = '{DatabaseName}'";


        #endregion

        #region Stats
        public const string StatsName = "ST_TempA_TransactionUtcDt";


        public static string CreateStatsSql = $"CREATE STATISTICS {StatsName} ON dbo.{TableName}(TransactionUtcDt) WITH SAMPLE 1 PERCENT";

        public static string CreateStatsMetadataSql = $@"
            INSERT INTO DOI.[Statistics](DatabaseName       ,SchemaName ,TableName      ,StatisticsName   ,StatisticsColumnList_Desired ,SampleSizePct_Desired  ,IsFiltered_Desired ,FilterPredicate_Desired,IsIncremental_Desired  ,NoRecompute_Desired,LowerSampleSizeToDesired   ,ReadyToQueue)
            VALUES(                     N'{DatabaseName}'   ,N'dbo'     , N'{TableName}','{StatsName}'    ,'TransactionUtcDt'           , 0                    , 0                 , NULL                  , 0                     , 0                 , 0                         ,  1)";

        public static string DropStatsSql = $"DROP STATISTICS dbo.{TableName}.{StatsName}";

        public static string RefreshMetadata_SysStatsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStats @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStatsColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStats_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_Statistics_UpdateData @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysStatsColumnsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStats @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStatsColumns @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysDmDbStatsPropertiesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStats @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStatsColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDmDbStatsProperties @DatabaseName = '{DatabaseName}'";


        #endregion

        #region SysTypes

        public static string UserDefinedTypeName = "TestType";
        public static string CreateUserDefinedTypeSql = $@"CREATE TYPE {UserDefinedTypeName} FROM varchar(11) NOT NULL";
        public static string DropUserDefinedTypeSql = $@"DROP TYPE {UserDefinedTypeName}";

        public static string RefreshMetadata_SysTypesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTypes @DatabaseName = '{DatabaseName}'";
        #endregion

        #region RefreshMetadata

        public static string RefreshMetadata_SysPartitionsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitions @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysAllocationUnitsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysAllocationUnits @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysColumnsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'";

        #endregion


        public const string MetadataDeleteSql = @"EXEC [Utility].[spDeleteAllMetadataFromDatabase] @DatabaseName = 'DOIUnitTests', @OneTimeTearDown = 0";

       
    }
}
