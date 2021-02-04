using System;
using System.Data.SqlClient;
using DOI.Tests.Integration.Models;
using Simple.Data.Ado.Schema;


namespace DOI.Tests.TestHelpers.Metadata.SystemMetadata
{
    public class SystemMetadataHelper
    {
        public SqlHelper sqlHelper = new SqlHelper();

        #region Databases

        public const string DatabaseName = "DOIUnitTests";
        public static string RefreshMetadata_SysDatabasesSql = $@"EXEC DOI.spRefreshMetadata_System_SysDatabases @DatabaseName = '{DatabaseName}'";

        #endregion

        #region FileGroups

        public const string FilegroupName = "Test1FG1";
        public const string Filegroup2Name = "Test1FG2";
        public static string CreateFilegroupSql = $@"ALTER DATABASE {DatabaseName} ADD FILEGROUP {FilegroupName};";
        public static string CreateFilegroup2Sql = $@"ALTER DATABASE {DatabaseName} ADD FILEGROUP {Filegroup2Name};";

        public static string RefreshStorageContainers_FilegroupsAndFiles = $@"EXEC DOI.spRefreshStorageContainers_FilegroupsAndFiles @DatabaseName = '{DatabaseName}'";
        public static string RefreshStorageContainers_PartitionFunctions = $@"EXEC DOI.spRefreshStorageContainers_PartitionFunctions @DatabaseName = '{DatabaseName}'";
        public static string RefreshStorageContainers_PartitionSchemes = $@"EXEC DOI.spRefreshStorageContainers_PartitionSchemes @DatabaseName = '{DatabaseName}'";
        
        public static string DropFilegroupSql = $@"ALTER DATABASE {DatabaseName} REMOVE FILEGROUP {FilegroupName};";
        public static string DropFilegroup2Sql = $@"ALTER DATABASE {DatabaseName} REMOVE FILEGROUP {Filegroup2Name};";
        
        public static string RefreshMetadata_SysFilegroupsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysFilegroups @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionSchemes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces @DatabaseName = '{DatabaseName}'    
            EXEC DOI.[spRefreshMetadata_User_PartitionFunctions_UpdateData] @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysDataSpacesSql = $"EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'";
        public static string RefreshMetadata_SysDestinationDataSpacesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysFilegroups @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionSchemes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces @DatabaseName = '{DatabaseName}'";
        

        #endregion
        #region DatabaseFiles

        public static string DatabaseFileName = "testDBFileName";
        public static string DatabaseFileName_Partition1 = "testDBFileName_Partition1";
        public static string DatabaseFileName_Partition2 = "testDBFileName_Partition2";

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

        public static string CreateDatabaseFiles_PartitionedSql = $@"
        ALTER DATABASE {DatabaseName}
            ADD FILE
            (
                NAME = {DatabaseFileName_Partition1},
                FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\{DatabaseFileName_Partition1}.ndf',
                SIZE = 5MB,
                MAXSIZE = 100MB,
                FILEGROWTH = 5MB
            )
            TO FILEGROUP {FilegroupName}

        ALTER DATABASE {DatabaseName}
            ADD FILE
            (
                NAME = {DatabaseFileName_Partition2},
                FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\{DatabaseFileName_Partition2}.ndf',
                SIZE = 5MB,
                MAXSIZE = 100MB,
                FILEGROWTH = 5MB
            )
            TO FILEGROUP {Filegroup2Name}";

        public static string DropDatabaseFileSql = $@"ALTER DATABASE {DatabaseName} REMOVE FILE {DatabaseFileName}";
        public static string DropDatabaseFiles_PartitionedSql = $@"
            ALTER DATABASE {DatabaseName} REMOVE FILE {DatabaseFileName_Partition1}
            ALTER DATABASE {DatabaseName} REMOVE FILE {DatabaseFileName_Partition2}";


        public static string RefreshMetadata_SysDatabaseFilesSql = $"EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'";
        public static string RefreshMetadata_SysMasterFilesSql = $"EXEC DOI.spRefreshMetadata_System_SysMasterFiles @DatabaseName = '{DatabaseName}'";
        public static string RefreshMetadata_SysDmOsVolumeStatsSql = $@"
        EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}' 
        EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats @DatabaseName = '{DatabaseName}'";

        #endregion
        #region PartitionFunctions

        public const string PartitionFunctionNameYearly = "pfTestsYearly";

        public static string CreatePartitionFunctionYearlySql = $"CREATE PARTITION FUNCTION [{PartitionFunctionNameYearly}](datetime2(7)) AS RANGE RIGHT FOR VALUES (N'2016-01-01T00:00:00.000')";

        public static string DropPartitionFunctionYearlySql = $"IF EXISTS(SELECT 'True' FROM sys.partition_functions WHERE name = '{PartitionFunctionNameYearly}') DROP PARTITION FUNCTION {PartitionFunctionNameYearly}";

        public const string PartitionFunctionNameMonthly = "pfTestsMonthly";

        public static string CreatePartitionFunctionMonthlySql = $"CREATE PARTITION FUNCTION [{PartitionFunctionNameMonthly}](datetime2(7)) AS RANGE RIGHT FOR VALUES (N'2016-01-01T00:00:00.000')";

        public static string DropPartitionFunctionMonthlySql = $"IF EXISTS(SELECT 'True' FROM sys.partition_functions WHERE name = '{PartitionFunctionNameMonthly}') DROP PARTITION FUNCTION {PartitionFunctionNameMonthly}";

        public static string RefreshMetadata_SysPartitionFunctionsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysFileGroups @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionSchemes @DatabaseName = '{DatabaseName}'
";

        public static string RefreshMetadata_PartitionFunctionsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysFileGroups @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionRangeValues @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionSchemes @DatabaseName = '{DatabaseName}'";

        public static string CreatePartitionFunctionYearlyMetadataSql = $@"
            INSERT INTO DOI.PartitionFunctions( DatabaseName    ,PartitionFunctionName              ,PartitionFunctionDataType  ,BoundaryInterval   ,NumOfFutureIntervals   ,InitialDate    ,UsesSlidingWindow  ,SlidingWindowSize  ,IsDeprecated   ,LastBoundaryDate)
            VALUES(                             '{DatabaseName}', '{PartitionFunctionNameYearly}'   ,'DATETIME2'                ,'Yearly'           ,1                      ,'2016-01-01'   ,0                  ,NULL               ,0              ,N'2021-01-01')";

        public string GetPartitionsFrom_vwPartitionFunctionPartitionsYearly = $@"
            SELECT * FROM DOI.vwPartitionFunctionPartitions WHERE DatabaseName = '{DatabaseName}' AND PartitionFunctionName = '{PartitionFunctionNameYearly}'";

        public static string CreatePartitionFunctionMonthlyMetadataSql = $@"
            INSERT INTO DOI.PartitionFunctions( DatabaseName    ,PartitionFunctionName              ,PartitionFunctionDataType  ,BoundaryInterval   ,NumOfFutureIntervals   ,InitialDate    ,UsesSlidingWindow  ,SlidingWindowSize  ,IsDeprecated   ,LastBoundaryDate)
            VALUES(                             '{DatabaseName}', '{PartitionFunctionNameMonthly}'  ,'DATETIME2'                ,'Monthly'           ,12                    ,'2016-01-01'   ,0                  ,NULL               ,0              ,N'2021-12-01')";

        public string GetPartitionsFrom_vwPartitionFunctionPartitionsMonthly = $@"
            SELECT * FROM DOI.vwPartitionFunctionPartitions WHERE DatabaseName = '{DatabaseName}' AND PartitionFunctionName = '{PartitionFunctionNameMonthly}'";

        #endregion
        #region PartitionSchemes

        public const string PartitionSchemeNameYearly = "psTestsYearly";
        public const string PartitionSchemeNameMonthly = "psTestsMonthly";


        public static string CreatePartitionSchemeYearlySql = $"CREATE PARTITION SCHEME [{PartitionSchemeNameYearly}] AS PARTITION [{PartitionFunctionNameYearly}] TO ([{FilegroupName}], [{Filegroup2Name}])";
        public static string CreatePartitionSchemeMonthlySql = $"CREATE PARTITION SCHEME [{PartitionSchemeNameMonthly}] AS PARTITION [{PartitionFunctionNameMonthly}] TO ([{FilegroupName}], [{Filegroup2Name}])";


        public static string DropPartitionSchemeYearlySql = $"IF EXISTS(SELECT 'True' FROM sys.partition_schemes WHERE name = '{PartitionSchemeNameYearly}') DROP PARTITION SCHEME {PartitionSchemeNameYearly}";
        public static string DropPartitionSchemeMonthlySql = $"IF EXISTS(SELECT 'True' FROM sys.partition_schemes WHERE name = '{PartitionSchemeNameMonthly}') DROP PARTITION SCHEME {PartitionSchemeNameMonthly}";


        public static string RefreshMetadata_SysPartitionSchemesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysFilegroups @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionRangeValues @DatabaseName = '{DatabaseName}'
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
        public const string TableName_Partitioned = "TempA_Partitioned";
        public const string PartitionColumnName = "TransactionUtcDt";
        public const string PartitionedTable_PKColumnList = "TempAId,TransactionUtcDt";

        public static string DeleteTableSql = $"DELETE FROM dbo.{TableName}";

        public static string CreateTableSql = $@"
        CREATE TABLE dbo.{TableName}(
            TempAId uniqueidentifier NOT NULL,
            TransactionUtcDt datetime2(7) NOT NULL,
            IncludedColumn VARCHAR(50) NULL,
            TextCol VARCHAR(8000) NULL 
 
            CONSTRAINT {PKIndexName}
                PRIMARY KEY NONCLUSTERED (TempAId)
                    WITH (  PAD_INDEX = ON,
                            DATA_COMPRESSION = PAGE)
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
        VALUES                  ('{DatabaseName}'   , 'dbo'	        ,'{TableName}'				,NULL						, 'PRIMARY'							, 0					,  1)

        INSERT INTO DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, 
                                        IsFiltered_Desired, FilterPredicate_Desired, Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, 
                                        OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, Storage_Desired, StorageType_Desired, 
                                        PartitionFunction_Desired, PartitionColumn_Desired)
        VALUES (N'{DatabaseName}', N'dbo', N'{TableName}', N'{PKIndexName}', 1, 1, 0, 0, 'TempAId ASC', NULL,  
                0, NULL, 100, 1, 0, 0, 0, 
                0, 0, 1, 1, N'PAGE', 'PRIMARY', N'ROWS_FILEGROUP', 
                NULL, NULL)";

        public static string CreateChildTableMetadataSql = $@"
        DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{ChildTableName}'
        INSERT INTO DOI.Tables  (DatabaseName       , SchemaName    ,TableName					,PartitionColumn			,Storage_Desired					, IntendToPartition	,  ReadyToQueue) 
        VALUES                  ('{DatabaseName}'   , 'dbo'	        ,'{ChildTableName}'			,NULL						, 'PRIMARY'							, 0					,  1)";


        public static string CreatePartitionedTableYearlySql = $@"
        CREATE TABLE dbo.{TableName_Partitioned}(
            TempAId uniqueidentifier NOT NULL,
            TransactionUtcDt datetime2(7) NOT NULL
                CONSTRAINT Def_{TableName_Partitioned}_TransactionUtcDt
                    DEFAULT SYSDATETIME(),
            IncludedColumn VARCHAR(50) NULL
                CONSTRAINT Chk_{TableName_Partitioned}_IncludedColumn
                    CHECK (IncludedColumn <> '!@#$%'),
            TextCol VARCHAR(8000) NULL 
            CONSTRAINT {PKIndexName_Partitioned}
                PRIMARY KEY NONCLUSTERED (TempAId, TransactionUtcDt)
        )
        ON {PartitionSchemeNameYearly}(TransactionUtcDt)";       
        
        public static string CreatePartitionedTableMonthlySql = $@"
        CREATE TABLE dbo.{TableName_Partitioned}(
            TempAId uniqueidentifier NOT NULL,
            TransactionUtcDt datetime2(7) NOT NULL
                CONSTRAINT Def_{TableName_Partitioned}_TransactionUtcDt
                    DEFAULT SYSDATETIME(),
            IncludedColumn VARCHAR(50) NULL
                CONSTRAINT Chk_{TableName_Partitioned}_IncludedColumn
                    CHECK (IncludedColumn <> '!@#$%'),
            TextCol VARCHAR(8000) NULL 
            CONSTRAINT {PKIndexName_Partitioned}
                PRIMARY KEY NONCLUSTERED (TempAId, TransactionUtcDt)
        )
        ON {PartitionSchemeNameMonthly}(TransactionUtcDt)";

        public static string CreatePartitionedTableYearlyMetadataSql = $@"
        DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName_Partitioned}'
        INSERT INTO DOI.Tables  (DatabaseName       , SchemaName    ,TableName					,PartitionColumn			,PartitionFunctionName					, IntendToPartition	,  ReadyToQueue) 
        VALUES                  ('{DatabaseName}'   , 'dbo'	        ,'{TableName_Partitioned}'	,'TransactionUtcDt'			, '{PartitionFunctionNameYearly}'			, 1					,  1);

        INSERT INTO DOI.DefaultConstraints( DatabaseName    ,SchemaName ,TableName                  ,ColumnName         ,DefaultDefinition, DefaultConstraintName)
        VALUES(                             '{DatabaseName}', N'dbo'    ,N'{TableName_Partitioned}' ,N'TransactionUtcDt',N'SYSDATETIME()', 'Def_{TableName_Partitioned}_TransactionUtcDt');

        INSERT INTO DOI.CheckConstraints(   DatabaseName    ,SchemaName ,TableName                  ,ColumnName         ,CheckDefinition                    ,IsDisabled , CheckConstraintName)
        VALUES(                             '{DatabaseName}', N'dbo'    ,N'{TableName_Partitioned}' ,N'IncludedColumn'  ,N'IncludedColumn <> ''!@#$%'''     ,0          , 'Chk_{TableName_Partitioned}_IncludedColumn');


        INSERT INTO DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, 
                                        IsFiltered_Desired, FilterPredicate_Desired, Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, 
                                        OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, Storage_Desired, StorageType_Desired, 
                                        PartitionFunction_Desired, PartitionColumn_Desired)
        VALUES (N'{DatabaseName}', N'dbo', N'{TableName_Partitioned}', N'{PKIndexName_Partitioned}', 1, 1, 0, 0, 'TempAId ASC', NULL,  
                0, NULL, 100, 1, 0, 0, 0, 
                0, 0, 1, 1, N'PAGE', '{PartitionSchemeNameMonthly}', N'PARTITION_SCHEME', 
                NULL, NULL)";
 
        public static string CreatePartitionedTableMonthlyMetadataSql = $@"
        DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName_Partitioned}'
        INSERT INTO DOI.Tables  (DatabaseName       , SchemaName    ,TableName					,PartitionColumn			,PartitionFunctionName					, IntendToPartition	,  ReadyToQueue) 
        VALUES                  ('{DatabaseName}'   , 'dbo'	        ,'{TableName_Partitioned}'	,'TransactionUtcDt'			,'{PartitionFunctionNameMonthly}'			, 1					,  1)

        INSERT INTO DOI.DefaultConstraints( DatabaseName    ,SchemaName ,TableName                  ,ColumnName         ,DefaultDefinition, DefaultConstraintName)
        VALUES(                             '{DatabaseName}', N'dbo'    ,N'{TableName_Partitioned}' ,N'TransactionUtcDt',N'SYSDATETIME()', 'Def_{TableName_Partitioned}_TransactionUtcDt');

        INSERT INTO DOI.CheckConstraints(   DatabaseName    ,SchemaName ,TableName                  ,ColumnName         ,CheckDefinition                    ,IsDisabled , CheckConstraintName)
        VALUES(                             '{DatabaseName}', N'dbo'    ,N'{TableName_Partitioned}' ,N'IncludedColumn'  ,N'IncludedColumn <> ''!@#$%'''     ,0          , 'Chk_{TableName_Partitioned}_IncludedColumn');

        INSERT INTO DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, 
                                        IsFiltered_Desired, FilterPredicate_Desired, Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, 
                                        OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, Storage_Desired, StorageType_Desired, 
                                        PartitionFunction_Desired, PartitionColumn_Desired)
        VALUES (N'{DatabaseName}', N'dbo', N'{TableName_Partitioned}', N'{PKIndexName_Partitioned}', 1, 1, 0, 0, 'TempAId ASC', NULL,  
                0, NULL, 100, 1, 0, 0, 0, 
                0, 0, 1, 1, N'PAGE', '{PartitionSchemeNameYearly}', N'PARTITION_SCHEME', 
                NULL, NULL)";

        public static string InsertOneRowIntoTableSql = $@"INSERT INTO dbo.{TableName}(TempAId, TransactionUtcDt, IncludedColumn, TextCol) VALUES('{Guid.Parse("0525CED4-4F7B-4212-B511-44D13C129DA9")}', SYSDATETIME(), 'BLA', 'BLA')";

        public static string InsertOneRowIntoEachPartitionSql = $@"
            INSERT INTO dbo.{TableName_Partitioned}(TempAId, TransactionUtcDt, IncludedColumn, TextCol) 
            VALUES  ('{Guid.Parse("0525CED4-4F7B-4212-B511-44D13C129DA9")}', '2015-01-01', 'BLA', 'BLA'),
                    ('{Guid.Parse("B6696AE4-74B8-4565-AB57-9242C170A846")}', '2016-01-01', 'BLA', 'BLA')";

        public static string DropTableSql = $"DROP TABLE IF EXISTS dbo.{TableName}";
        public static string DropTableMetadataSql = $@"DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}'";
        public static string DropChildTableSql = $"DROP TABLE IF EXISTS dbo.{ChildTableName}";
        public static string DropChildTableMetadataSql = $@"DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{ChildTableName}'";
        public static string DropPartitionedTableSql = $"DROP TABLE IF EXISTS dbo.{TableName_Partitioned}";
        public static string DropPartitionedTableMetadataSql = $@"DELETE DOI.Tables WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName_Partitioned}'";



        public static string RefreshMetadata_SysTablesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysSchemas @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_Tables_UpdateData @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_PartitionedTablesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysFilegroups @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionSchemes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces @DatabaseName = '{DatabaseName}'    
            EXEC DOI.[spRefreshMetadata_User_PartitionFunctions_UpdateData] @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysSchemas @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexColumns @DatabaseName = '{DatabaseName}'
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
        public const string CIndexName = "CDX_TempA";
        public const string NCIndexName = "IDX_TempA";
        public const string NCCIIndexName = "NCCI_TempA";
        public const string CCIIndexName = "CCI_TempA";
        public const string PKIndexName = "PK_TempA";


        public const string CIndexName_Partitioned = "CDX_TempA_Partitioned";
        public const string NCCIIndexName_ColumnStore_Partitioned = "NCCI_TempA_Partitioned";
        public const string PKIndexName_Partitioned = "PK_TempA_Partitioned";


        //clustered index
        public static string CreateCIndexSql = $"DROP INDEX IF EXISTS {CIndexName} ON dbo.{TableName}; CREATE CLUSTERED INDEX {CIndexName} ON dbo.{TableName}(TempAId) WITH (FILLFACTOR = 100, PAD_INDEX = ON, DATA_COMPRESSION = PAGE) ON [PRIMARY] ";

        public static string CreateCIndexMetadataSql = $@"
            INSERT INTO DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, 
                                            IsFiltered_Desired, FilterPredicate_Desired, Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, 
                                            OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, Storage_Desired, StorageType_Desired, 
                                            PartitionFunction_Desired, PartitionColumn_Desired)
            VALUES (N'{DatabaseName}', N'dbo', N'{TableName}', N'{CIndexName}', 0, 0, 0, 1, 'TempAId ASC', NULL,  
                    0, NULL, 100, 1, 0, 0, 0, 
                    0, 0, 1, 1, N'PAGE', 'PRIMARY', N'ROWS_FILEGROUP', 
                    NULL, NULL)";

        public static string DropCIndexMetadataSql = $"DELETE DOI.DOI.IndexesRowStore WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}' AND IndexName = '{CIndexName}'";


        public static string DropCIndexSql = $"DROP INDEX IF EXISTS {CIndexName} ON dbo.{TableName}";

        //NC index
        public static string CreateNCIndexSql = $"CREATE NONCLUSTERED INDEX {NCIndexName} ON dbo.{TableName}(TransactionUtcDt) WITH (FILLFACTOR = 100, PAD_INDEX = ON, DATA_COMPRESSION = PAGE) ON [PRIMARY] ";

        public static string CreateNCIndexMetadataSql = $@"
            INSERT INTO DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, 
                                            IsFiltered_Desired, FilterPredicate_Desired, Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, 
                                            OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, Storage_Desired, StorageType_Desired, 
                                            PartitionFunction_Desired, PartitionColumn_Desired)
            VALUES (N'{DatabaseName}', N'dbo', N'{TableName}', N'{NCIndexName}', 0, 0, 0, 0, 'TransactionUtcDt ASC', NULL,  
                    0, NULL, 100, 1, 0, 0, 0, 
                    0, 0, 1, 1, N'PAGE', 'PRIMARY', N'ROWS_FILEGROUP', 
                    NULL, NULL)";

        public static string DropNCIndexSql = $"DROP INDEX IF EXISTS {NCIndexName} ON dbo.{TableName}";

        public static string CreateFilteredNCIndexSql = $"CREATE NONCLUSTERED INDEX {NCIndexName} ON dbo.{TableName}(TransactionUtcDt) WHERE TempAId <> '{Guid.Empty}' WITH (FILLFACTOR = 100, PAD_INDEX = ON, DATA_COMPRESSION = PAGE) ON [PRIMARY] ";

        //NCCI index
        public static string CreateNCCIIndexSql = $"CREATE NONCLUSTERED COLUMNSTORE INDEX {NCCIIndexName} ON dbo.{TableName}(TransactionUtcDt) WITH (DATA_COMPRESSION = COLUMNSTORE)";

        public static string CreateNCCIIndexMetadataSql = $@"
            INSERT INTO DOI.IndexesColumnStore
                (DatabaseName, SchemaName, TableName, IndexName, IsClustered_Desired, ColumnList_Desired, IsFiltered_Desired, FilterPredicate_Desired,
                 OptionDataCompression_Desired, OptionDataCompressionDelay_Desired, Storage_Desired, StorageType_Desired, PartitionFunction_Desired,
                 PartitionColumn_Desired)
            VALUES(N'{DatabaseName}', N'dbo', N'{TableName}', N'{NCCIIndexName}', 0, N'TransactionUtcDt ASC', 0, NULL, 
                'COLUMNSTORE', 0, N'PRIMARY', N'ROWS_FILEGROUP', NULL, 
                NULL)";

        public static string DropNCCIndexMetadataSql = $"DELETE DOI.DOI.IndexesColumnStore WHERE DatabaseName = '{DatabaseName}' AND TableName = '{TableName}' AND IndexName = '{CIndexName}'";

        public static string DropNCCIIndexSql = $"DROP INDEX IF EXISTS {NCCIIndexName} ON dbo.{TableName}";

        //CCI index
        public static string CreateCCIIndexSql = $"CREATE CLUSTERED COLUMNSTORE INDEX {CCIIndexName} ON dbo.{TableName} WITH (DATA_COMPRESSION = COLUMNSTORE)";

        public static string CreateCCIIndexMetadataSql = $@"
            INSERT INTO DOI.IndexesColumnStore
                (DatabaseName, SchemaName, TableName, IndexName, IsClustered_Desired, ColumnList_Desired, IsFiltered_Desired, FilterPredicate_Desired,
                 OptionDataCompression_Desired, OptionDataCompressionDelay_Desired, Storage_Desired, StorageType_Desired, PartitionFunction_Desired,
                 PartitionColumn_Desired)
            VALUES(N'{DatabaseName}', N'dbo', N'{TableName}', N'{CCIIndexName}', 1, NULL, 0, NULL, 
                'COLUMNSTORE', 0, N'PRIMARY', N'ROWS_FILEGROUP', NULL, 
                NULL)";

        public static string DropCCIIndexSql = $"DROP INDEX IF EXISTS {CCIIndexName} ON dbo.{TableName}";

        //PK index
        public static string DropPKIndexSql = $"IF EXISTS(SELECT 'True' FROM sys.indexes WHERE NAME = '{PKIndexName}') ALTER TABLE dbo.{TableName} DROP CONSTRAINT {PKIndexName}";
        public static string CreatePKIndexSql = $@" 
            IF NOT EXISTS(SELECT 'True' FROM sys.indexes WHERE NAME = '{PKIndexName}')
            BEGIN
                ALTER TABLE dbo.{TableName}
                    ADD CONSTRAINT {PKIndexName}
                        PRIMARY KEY NONCLUSTERED (TempAId)
                            WITH (  PAD_INDEX = ON,
                                    DATA_COMPRESSION = PAGE)
            END";

        //PARTITIONED INDEX

        public static string DropPartitionedPKIndexSql = $"IF EXISTS(SELECT 'True' FROM sys.indexes WHERE NAME = '{PKIndexName_Partitioned}') ALTER TABLE dbo.{TableName_Partitioned} DROP CONSTRAINT {PKIndexName_Partitioned}";


        public static string CreatePartitionedIndexYearlySql = $@"
            CREATE UNIQUE CLUSTERED INDEX {CIndexName_Partitioned} 
                ON dbo.{TableName_Partitioned}(TempAId, TransactionUtcDt) 
                    WITH (FILLFACTOR = 100, PAD_INDEX = ON, DATA_COMPRESSION = PAGE) 
                        ON {PartitionSchemeNameYearly}(TransactionUtcDt)";

        public static string CreatePartitionedIndexYearlyMetadataSql = $@"
            INSERT INTO DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, 
                                            IsFiltered_Desired, FilterPredicate_Desired, Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, 
                                            OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, Storage_Desired, StorageType_Desired, 
                                            PartitionFunction_Desired, PartitionColumn_Desired)
            VALUES (N'{DatabaseName}', N'dbo', N'{TableName_Partitioned}', N'{CIndexName_Partitioned}', 1, 0, 0, 1, 'TempAId ASC', NULL,  
                    0, NULL, 100, 1, 0, 0, 0, 
                    0, 0, 1, 1, N'PAGE', '{PartitionSchemeNameYearly}', N'PARTITION_SCHEME', 
                    '{PartitionFunctionNameYearly}', 'TransactionUtcDt')";

        public static string CreatePartitionedColumnStoreIndexYearlySql = $@"
            CREATE NONCLUSTERED COLUMNSTORE INDEX {NCCIIndexName_ColumnStore_Partitioned} 
                ON dbo.{TableName_Partitioned}(IncludedColumn) 
                    WITH (DATA_COMPRESSION = COLUMNSTORE) 
                        ON {PartitionSchemeNameYearly}(TransactionUtcDt)";

        public static string CreatePartitionedColumnStoreIndexYearlyMetadataSql = $@"
            INSERT INTO DOI.IndexesColumnStore
                (DatabaseName, SchemaName, TableName, IndexName, IsClustered_Desired, ColumnList_Desired, IsFiltered_Desired, FilterPredicate_Desired,
                 OptionDataCompression_Desired, OptionDataCompressionDelay_Desired, Storage_Desired, StorageType_Desired, PartitionFunction_Desired,
                 PartitionColumn_Desired)
            VALUES(N'{DatabaseName}', N'dbo', N'{TableName_Partitioned}', N'{NCCIIndexName_ColumnStore_Partitioned}', 0, N'IncludedColumn ASC', 0, NULL, 
                'COLUMNSTORE', 0, N'{PartitionSchemeNameYearly}', N'PARTITION_SCHEME', '{PartitionFunctionNameYearly}', 
                'TransactionUtcDt')";

        public static string CreatePartitionedIndexMonthlySql = $@"
            CREATE UNIQUE CLUSTERED INDEX {CIndexName_Partitioned} 
                ON dbo.{TableName_Partitioned}(TempAId, TransactionUtcDt) 
                    WITH (FILLFACTOR = 100, PAD_INDEX = ON, DATA_COMPRESSION = PAGE) 
                        ON {PartitionSchemeNameMonthly}(TransactionUtcDt)";

        public static string CreatePartitionedIndexMonthlyMetadataSql = $@"
            INSERT INTO DOI.IndexesRowStore(DatabaseName, SchemaName, TableName, IndexName, IsUnique_Desired, IsPrimaryKey_Desired, IsUniqueConstraint_Desired, IsClustered_Desired, KeyColumnList_Desired, IncludedColumnList_Desired, 
                                            IsFiltered_Desired, FilterPredicate_Desired, Fillfactor_Desired, OptionPadIndex_Desired, OptionStatisticsNoRecompute_Desired, OptionStatisticsIncremental_Desired, OptionIgnoreDupKey_Desired, 
                                            OptionResumable_Desired, OptionMaxDuration_Desired, OptionAllowRowLocks_Desired, OptionAllowPageLocks_Desired, OptionDataCompression_Desired, Storage_Desired, StorageType_Desired, 
                                            PartitionFunction_Desired, PartitionColumn_Desired)
            VALUES (N'{DatabaseName}', N'dbo', N'{TableName_Partitioned}', N'{CIndexName_Partitioned}', 1, 0, 0, 1, 'TempAId ASC', NULL,  
                    0, NULL, 100, 1, 0, 0, 0, 
                    0, 0, 1, 1, N'PAGE', '{PartitionSchemeNameMonthly}', N'PARTITION_SCHEME', 
                    '{PartitionFunctionNameMonthly}', 'TransactionUtcDt')";

        public static string CreatePartitionedColumnStoreIndexMonthlySql = $@"
            CREATE NONCLUSTERED COLUMNSTORE INDEX {NCCIIndexName_ColumnStore_Partitioned} 
                ON dbo.{TableName_Partitioned}(IncludedColumn) 
                    WITH (DATA_COMPRESSION = COLUMNSTORE) 
                        ON {PartitionSchemeNameMonthly}(TransactionUtcDt)";

        public static string CreatePartitionedColumnStoreIndexMonthlyMetadataSql = $@"
            INSERT INTO DOI.IndexesColumnStore
                (DatabaseName, SchemaName, TableName, IndexName, IsClustered_Desired, ColumnList_Desired, IsFiltered_Desired, FilterPredicate_Desired,
                 OptionDataCompression_Desired, OptionDataCompressionDelay_Desired, Storage_Desired, StorageType_Desired, PartitionFunction_Desired,
                 PartitionColumn_Desired)
            VALUES(N'{DatabaseName}', N'dbo', N'{TableName_Partitioned}', N'{NCCIIndexName_ColumnStore_Partitioned}', 0, N'IncludedColumn ASC', 0, NULL, 
                'COLUMNSTORE', 0, N'{PartitionSchemeNameMonthly}', N'PARTITION_SCHEME', '{PartitionFunctionNameMonthly}', 
                'TransactionUtcDt')";

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
            EXEC DOI.spRefreshMetadata_System_SysIndexPhysicalStats @DatabaseName = '{DatabaseName}'
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

        public static string RefreshMetadata_SysIndexesPartitionsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysFilegroups @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionSchemes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysSchemas @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexColumns @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStats @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDestinationDataSpaces @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysAllocationUnits @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDatabaseFiles @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysDmOsVolumeStats @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexPhysicalStats @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_Tables_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_IndexesRowStore_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_IndexesColumnStore_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_IndexPartitions_RowStore_InsertData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_IndexPartitions_ColumnStore_InsertData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_IndexPartitions_RowStore_UpdateData @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_User_IndexPartitions_ColumnStore_UpdateData @DatabaseName = '{DatabaseName}'";


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
