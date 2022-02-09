using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.RunTests.Foreign_Keys
{
    public static class ForeignKeySqlStatements
    {
        public const string DatabaseName = "DOIUnitTests";

        public static string SetupFKTablesSql = @"
            CREATE TABLE dbo.FKParentTable(
                FKParentTableId uniqueidentifier NOT NULL PRIMARY KEY CLUSTERED,
                TransactionUtcDt datetime2(7) NOT NULL,
                IncludedColumn VARCHAR(50) NULL,
                TextCol VARCHAR(8000) NULL)

            CREATE TABLE dbo.FKChildTable(
                FKChildTableId uniqueidentifier NOT NULL PRIMARY KEY CLUSTERED,
                FKParentTableId uniqueidentifier NOT NULL,
                TransactionUtcDt datetime2(7) NOT NULL)

            --metadata tables
            CREATE TABLE DOI.FKParentTable2(
                FKParentTableId uniqueidentifier NOT NULL PRIMARY KEY CLUSTERED,
                TransactionUtcDt datetime2(7) NOT NULL,
                IncludedColumn VARCHAR(50) NULL,
                TextCol VARCHAR(8000) NULL)

            CREATE TABLE DOI.FKChildTable2(
                FKChildTableId uniqueidentifier NOT NULL PRIMARY KEY CLUSTERED,
                FKParentTableId uniqueidentifier NOT NULL,
                TransactionUtcDt datetime2(7) NOT NULL)

";

        public static string InsertFKMetadata = $@"
            DELETE T FROM DOI.ForeignKeys t 
            WHERE  DatabaseName = '{DatabaseName}'
                AND (ParentTableName  IN ('FKChildTable','FKParentTable','FKChildTable2','FKParentTable2')
                    OR t.ReferencedTableName IN ('FKChildTable','FKParentTable','FKChildTable2','FKParentTable2'))

            INSERT DOI.ForeignKeys 
                    ([DatabaseName], [ParentSchemaName] , [ParentTableName] , [ParentColumnList_Desired], [ReferencedSchemaName]  , [ReferencedTableName] , [ReferencedColumnList_Desired]) 
            VALUES	(N'{DatabaseName}', N'dbo'	        , N'FKChildTable'   , N'FKParentTableId'        , N'dbo'                  , N'FKParentTable'      , N'FKParentTableId'),
                    (N'{DatabaseName}', N'dbo'          , N'FKChildTable2'  , N'FKParentTableId'        , N'dbo'                  , N'FKParentTable2'      , N'FKParentTableId')";

        public static string TearDownSql = @"
            DROP TABLE IF EXISTS dbo.FKChildTable

            DROP TABLE IF EXISTS dbo.FKParentTable

            DROP TABLE IF EXISTS DOI.FKChildTable2

            DROP TABLE IF EXISTS DOI.FKParentTable2";

        public static string OneTimeTearDownSql = $@"
            EXEC DOI.spForeignKeysAdd
                @DatabaseName = '{DatabaseName}'

            EXEC DOI.spEnableDisableAllFKs
                @Action = 'DISABLE'";

        public static string DropParentFkSql = $@"
            EXEC DOI.spForeignKeysDrop
                @DatabaseName = '{DatabaseName}',
                @ParentSchemaName = 'dbo',
                @ParentTableName = 'FKChildTable'";

        public static string DropParentFkMetadataOnlySql = $@"
            EXEC DOI.spForeignKeysDrop
                @DatabaseName = '{DatabaseName}',
                @ParentSchemaName = 'dbo',
                @ParentTableName = 'FKChildTable'";

        public static string DropReferencingFkSql = $@"
            EXEC DOI.spForeignKeysDrop
                @DatabaseName = '{DatabaseName}',
                @ReferencedSchemaName = 'dbo',
                @ReferencedTableName = 'FKParentTable'";

        public static string DropReferencingFkMetadataOnlySql = $@"
            EXEC DOI.spForeignKeysDrop
                @DatabaseName = '{DatabaseName}',
                @ReferencedSchemaName = 'dbo',
                @ReferencedTableName = 'FKParentTable'";

        public static string CreateParentFkSql = $@"
            EXEC DOI.spForeignKeysAdd
                @DatabaseName = '{DatabaseName}',
                @ParentSchemaName = 'dbo',
                @ParentTableName = 'FKChildTable',
                @UseExistenceCheck = 1";

        public static string CreateParentFkMetadataOnlySql = $@"
            EXEC DOI.spForeignKeysAdd
                @DatabaseName = '{DatabaseName}',
                @ParentSchemaName = 'dbo',
                @ParentTableName = 'FKChildTable2',
                @UseExistenceCheck = 1";

        public static string CreateReferencingFkSql = $@"
            EXEC DOI.spForeignKeysAdd
                @DatabaseName = '{DatabaseName}',
                @ReferencedSchemaName = 'dbo',
                @ReferencedTableName = 'FKParentTable',
                @UseExistenceCheck = 1";

        public static string CreateReferencingFkMetadataOnlySql = $@"
            EXEC DOI.spForeignKeysAdd
                @DatabaseName = '{DatabaseName}',
                @ReferencedSchemaName = 'dbo',
                @ReferencedTableName = 'FKParentTable2',
                @UseExistenceCheck = 1";

        public static string EnableFkSql = $@"
            EXEC DOI.spEnableDisableAllFKs
                @DatabaseName = '{DatabaseName}',
                @Action = 'ENABLE'";

        public static string EnableFkMetadataOnlySql = $@"
            EXEC DOI.spEnableDisableAllFKs
                @DatabaseName = '{DatabaseName}',
                @Action = 'ENABLE'";

        public static string DisableFkSql = $@"
            EXEC DOI.spEnableDisableAllFKs
                @DatabaseName = '{DatabaseName}',
                @Action = 'DISABLE'";

        public static string DisableFkMetadataOnlySql = $@"
            EXEC DOI.spEnableDisableAllFKs
                @DatabaseName = '{DatabaseName}',
                @Action = 'DISABLE'";

        public static string VerifyFkExistsSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                WHERE name = 'FK_FKChildTable_FKParentTable_FKParentTableId'";

        public static string VerifyFkExistsMetadataOnlySql = @"
                SELECT  COUNT(*) FROM DOI.ForeignKeys  FK
                WHERE parentschemaname = 'dbo'";

        public static string VerifyAllFksExistsSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE name = 'FK_FKChildTable_FKParentTable_FKParentTableId'";

        public static string VerifyEnabledNonMetadataFksExistSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE is_disabled = 0";

        public static string VerifyDisabledNonMetadataFksExistSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE is_disabled = 1";

        public static string VerifyDisabledMetadataOnlyFksExistSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE is_disabled = 1";

        public static string CreateAllFksSql = $@"
            EXEC DOI.spForeignKeysAdd
                @DatabaseName = '{DatabaseName}'";

        public static string CreateAllFksMetadataOnlySql = $@"
            EXEC DOI.spForeignKeysAdd
                @DatabaseName = '{DatabaseName}'";

        public static string CountOfFKsInMetadataSql = @"
            SELECT COUNT(*)
            FROM DOI.ForeignKeys";

        public static string CountOfMetadataTableFKsInMetadataSql = @"
            SELECT COUNT(*)
            FROM DOI.ForeignKeys";

        public static string CountOfFKsOnSqlServerSql = @"
            SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id";

        public static string CountOfMetadataTableFKsOnSqlServer = @"
            SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE s.name = 'dbo'";
    }
}
