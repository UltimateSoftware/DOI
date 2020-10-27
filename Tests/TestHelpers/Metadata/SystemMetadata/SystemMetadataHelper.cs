using System.Data.SqlClient;
using DOI.Tests.Integration.Models;


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

        public static string CreateTableSql = $@"
        CREATE TABLE dbo.{TableName}(
            TempAId uniqueidentifier NOT NULL,
            TransactionUtcDt datetime2(7) NOT NULL,
            IncludedColumn VARCHAR(50) NULL,
            TextCol VARCHAR(8000) NULL 
        )";

        public static string DropTableSql = $"DROP TABLE IF EXISTS dbo.{TableName}";

        public static string RefreshMetadata_SysTablesSql = $"EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'";

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

        #region Indexes
        public const string IndexName = "CDX_TempA_TempAId";


        public static string CreateIndexSql = $"CREATE UNIQUE CLUSTERED INDEX {IndexName} ON dbo.TempA(TempAId)";

        public static string DropIndexSql = $"DROP INDEX IF EXISTS {IndexName} ON dbo.TempA";

        public static string RefreshMetadata_SysIndexesSql = $@"
            EXEC DOI.spRefreshMetadata_System_SysTables @DatabaseName = '{DatabaseName}'
            EXEC DOI.spRefreshMetadata_System_SysIndexes @DatabaseName = '{DatabaseName}'";

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
