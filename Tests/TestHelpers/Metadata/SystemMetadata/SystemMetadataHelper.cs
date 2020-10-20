using System.Data.SqlClient;


namespace DOI.Tests.TestHelpers.Metadata.SystemMetadata
{
    public class SystemMetadataHelper
    {
        private SqlHelper sqlHelper = new SqlHelper();
        public const string DatabaseName = "DOIUnitTests";
        public static string RefreshMetadata_SysDatabasesSql = $@"EXEC DOI.spRefreshMetadata_System_SysDatabases @DatabaseName = '{DatabaseName}'";

        public static string CreateSchemaSql = "CREATE SCHEMA TEST AUTHORIZATION DBO";
        public static string DropSchemaSql = "DROP SCHEMA TEST";
        public static string RefreshMetadata_SysSchemasSql = $"EXEC DOI.spRefreshMetadata_System_SysSchemas @DatabaseName = {DatabaseName}";

        public const string CreateTableSql = @"
        CREATE TABLE dbo.TempA(
            TempAId uniqueidentifier NOT NULL,
            TransactionUtcDt datetime2(7) NOT NULL,
            IncludedColumn VARCHAR(50) NULL,
            TextCol VARCHAR(8000) NULL 
        )";

        public const string MetadataDeleteSql = @"
        EXEC [Utility].[spDeleteAllMetadataFromDatabase] 
            @DatabaseName = 'DOIUnitTests'";

       
    }
}