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

        public static string RefreshMetadata_SysPartitionFunctionsSql = $"EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysPartitionRangeValuesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysPartitionFunctions @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysPartitionRangeValues @DatabaseName = '{DatabaseName}'";
        

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
        public static string DropSchemaSql = "DROP SCHEMA TEST";
        public static string RefreshMetadata_SysSchemasSql = $"EXEC DOI.spRefreshMetadata_System_SysSchemas @DatabaseName = {DatabaseName}";
        #endregion

        #region Tables

        public const string TableName = "TempA";
        public const string ChildTableName = "TempB";

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

        public static string DropTableSql = $"DROP TABLE IF EXISTS dbo.{ChildTableName}";
        public static string DropChildTableSql = $"DROP TABLE IF EXISTS dbo.{ChildTableName}";


        public static string RefreshMetadata_SysTablesSql = $"EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'";

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

        public static string TriggerName = "trTempA";

        public static string CreateTriggersql = $@"
            CREATE TRIGGER dbo.{TriggerName} ON {TableName} FOR INSERT AS SELECT SYSDATETIME()";

        public static string DropTriggersql = $@"DROP TRIGGER dbo.{TriggerName}";

        public static string RefreshMetadata_SysTriggersSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysTriggers @DatabaseName = '{DatabaseName}'";

        #endregion

        #region SysForeignKeys

        public static string ForeignKeyName = "FK_TempB_TempAId";

        public static string CreateForeignKeySql = $@"
            ALTER TABLE dbo.{ChildTableName} 
                ADD CONSTRAINT {ForeignKeyName}
                    FOREIGN KEY (TempAId) REFERENCES dbo.{TableName}(TempAId)";

        public static string DropForeignKeySql = $@"ALTER TABLE dbo.{ChildTableName} DROP CONSTRAINT {ForeignKeyName}";

        public static string RefreshMetadata_SysForeignKeysSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysForeignKeys @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysForeignKeyColumnsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysForeignKeys @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysForeignKeyColumns @DatabaseName = '{DatabaseName}'";

        

        #endregion

        #region Indexes
        public const string IndexName = "CDX_TempA_TempAId";


        public static string CreateIndexSql = $"CREATE UNIQUE CLUSTERED INDEX {IndexName} ON dbo.TempA(TempAId)";

        public static string DropIndexSql = $"DROP INDEX IF EXISTS {IndexName} ON dbo.TempA";

        public static string RefreshMetadata_SysIndexesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysIndexColumnsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexColumns @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysIndexPhysicalStatsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexPhysicalStats @DatabaseName = '{DatabaseName}'";


        #endregion

        #region Stats
        public const string StatsName = "ST_TempA_TransactionUtcDt";


        public static string CreateStatsSql = $"CREATE STATISTICS {StatsName} ON dbo.TempA(TransactionUtcDt) WITH SAMPLE 1 PERCENT";

        public static string DropStatsSql = $"DROP STATISTICS dbo.TempA.{StatsName}";

        public static string RefreshMetadata_SysStatsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStats @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysStatsColumnsSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStats @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysStatsColumns @DatabaseName = '{DatabaseName}'";

        public static string RefreshMetadata_SysDmDbStatsPropertiesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
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


        public const string MetadataDeleteSql = @"EXEC [Utility].[spDeleteAllMetadataFromDatabase] @DatabaseName = 'DOIUnitTests'";

       
    }
}
