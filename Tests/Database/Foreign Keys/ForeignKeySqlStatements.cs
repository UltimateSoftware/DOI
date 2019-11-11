using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reporting.Ingestion.Integration.Tests.Database.Foreign_Keys
{
    public static class ForeignKeySqlStatements
    {
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
            CREATE TABLE Utility.FKParentTable2(
                FKParentTableId uniqueidentifier NOT NULL PRIMARY KEY CLUSTERED,
                TransactionUtcDt datetime2(7) NOT NULL,
                IncludedColumn VARCHAR(50) NULL,
                TextCol VARCHAR(8000) NULL)

            CREATE TABLE Utility.FKChildTable2(
                FKChildTableId uniqueidentifier NOT NULL PRIMARY KEY CLUSTERED,
                FKParentTableId uniqueidentifier NOT NULL,
                TransactionUtcDt datetime2(7) NOT NULL)

";

        public static string InsertFKMetadata = @"
            DELETE T FROM Utility.ForeignKeys t 
            WHERE  t.ParentTableName  IN ('FKChildTable','FKParentTable','FKChildTable2','FKParentTable2')
                OR t.ReferencedTableName IN ('FKChildTable','FKParentTable','FKChildTable2','FKParentTable2')

            INSERT [Utility].[ForeignKeys] 
                    ([ParentSchemaName] , [ParentTableName] , [ParentColumnList], [ReferencedSchemaName]  , [ReferencedTableName] , [ReferencedColumnList]) 
            VALUES	(N'dbo'	            , N'FKChildTable'   , N'FKParentTableId', N'dbo'                  , N'FKParentTable'      , N'FKParentTableId')

            INSERT [Utility].[ForeignKeys] 
                    ([ParentSchemaName] , [ParentTableName] , [ParentColumnList], [ReferencedSchemaName]  , [ReferencedTableName] , [ReferencedColumnList]) 
            VALUES	(N'Utility'         , N'FKChildTable2'   , N'FKParentTableId', N'Utility'              , N'FKParentTable2'      , N'FKParentTableId')";

        public static string TearDownSql = @"
            DROP TABLE IF EXISTS dbo.FKChildTable

            DROP TABLE IF EXISTS dbo.FKParentTable

            DROP TABLE IF EXISTS Utility.FKChildTable2

            DROP TABLE IF EXISTS Utility.FKParentTable2";

        public static string OneTimeTearDownSql = @"
            EXEC Utility.spForeignKeysMetadataInsert

            EXEC Utility.spForeignKeysAdd

            EXEC dbo.spEnableDisableAllFKs
                @Action = 'DISABLE'";

        public static string DropParentFkSql = @"
            EXEC Utility.spForeignKeysDrop
                @ParentSchemaName = 'dbo',
                @ParentTableName = 'FKChildTable'";

        public static string DropParentFkMetadataOnlySql = @"
            EXEC Utility.spForeignKeysDrop
                @ParentSchemaName = 'dbo',
                @ParentTableName = 'FKChildTable'";

        public static string DropReferencingFkSql = @"
            EXEC Utility.spForeignKeysDrop
                @ReferencedSchemaName = 'dbo',
                @ReferencedTableName = 'FKParentTable'";

        public static string DropReferencingFkMetadataOnlySql = @"
            EXEC Utility.spForeignKeysDrop
                @ReferencedSchemaName = 'dbo',
                @ReferencedTableName = 'FKParentTable'";

        public static string CreateParentFkSql = @"
            EXEC Utility.spForeignKeysAdd
                @ParentSchemaName = 'dbo',
                @ParentTableName = 'FKChildTable',
                @UseExistenceCheck = 1";

        public static string CreateParentFkMetadataOnlySql = @"
            EXEC Utility.spForeignKeysAdd
                @ParentSchemaName = 'Utility',
                @ParentTableName = 'FKChildTable2',
                @UseExistenceCheck = 1";

        public static string CreateReferencingFkSql = @"
            EXEC Utility.spForeignKeysAdd
                @ReferencedSchemaName = 'dbo',
                @ReferencedTableName = 'FKParentTable',
                @UseExistenceCheck = 1";

        public static string CreateReferencingFkMetadataOnlySql = @"
            EXEC Utility.spForeignKeysAdd
                @ReferencedSchemaName = 'Utility',
                @ReferencedTableName = 'FKParentTable2',
                @UseExistenceCheck = 1";

        public static string EnableFkSql = @"
            EXEC dbo.spEnableDisableAllFKs
                @Action = 'ENABLE'";

        public static string EnableFkMetadataOnlySql = @"
            EXEC dbo.spEnableDisableAllFKs
                @Action = 'ENABLE'";

        public static string DisableFkSql = @"
            EXEC dbo.spEnableDisableAllFKs
                @Action = 'DISABLE'";

        public static string DisableFkMetadataOnlySql = @"
            EXEC dbo.spEnableDisableAllFKs
                @Action = 'DISABLE'";

        public static string VerifyFkExistsSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                WHERE name = 'FK_FKChildTable_FKParentTable_FKParentTableId'";

        public static string VerifyFkExistsMetadataOnlySql = @"
                SELECT  COUNT(*) FROM Utility.ForeignKeys  FK
                WHERE parentschemaname = 'utility'";

        public static string VerifyAllFksExistsSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE s.name <> 'Utility'
                WHERE name = 'FK_FKChildTable_FKParentTable_FKParentTableId'";

        public static string VerifyEnabledNonMetadataFksExistSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE s.name <> 'Utility'
                    AND is_disabled = 0";

        public static string VerifyDisabledNonMetadataFksExistSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE s.name <> 'Utility'
                    AND is_disabled = 1";

        public static string VerifyDisabledMetadataOnlyFksExistSql = @"
                SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE s.name = 'Utility'
                    AND is_disabled = 1";

        public static string CreateAllFksSql = @"
            EXEC Utility.spForeignKeysAdd";

        public static string CreateAllFksMetadataOnlySql = @"
            EXEC Utility.spForeignKeysAdd";

        public static string CountOfFKsInMetadataSql = @"
            SELECT COUNT(*)
            FROM Utility.ForeignKeys
            WHERE ParentSchemaName <> 'Utility'";

        public static string CountOfMetadataTableFKsInMetadataSql = @"
            SELECT COUNT(*)
            FROM Utility.ForeignKeys
            WHERE ParentSchemaName = 'Utility'";

        public static string CountOfFKsOnSqlServerSql = @"
            SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE s.name <> 'Utility'";

        public static string CountOfMetadataTableFKsOnSqlServer = @"
            SELECT COUNT(*)
                FROM sys.foreign_keys fk 
                    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
                    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE s.name = 'Utility'";
    }
}
