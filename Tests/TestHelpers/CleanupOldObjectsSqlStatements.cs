

namespace DOI.Tests.TestHelpers
{
    public static class CleanupOldObjectsSqlStatements
    {
        public static string CreateSP(string spName)
        {
            return $@"CREATE PROCEDURE dbo.{spName}
                      AS
                        SELECT 'TEST' as test";
        }

        public static string CreateTable(string tableName)
        {
            return $@"CREATE TABLE dbo.{tableName}(
	                    TempAId uniqueidentifier NOT NULL,
	                    TransactionUtcDt datetime2(7) NOT NULL,
	                    IncludedColumn VARCHAR(50) NULL
                    )";
        }

        public static string DDIStoreProcCount()
        {
            return @"SELECT COUNT(*) FROM sys.procedures WHERE name LIKE 'spDDI|_RefreshIndexStructures|_ManualScript|_%WasRunOn%' ESCAPE('|')";
        }

        public static string DoesDDIStoreProcExist(int minAgeInDays)
        {
            return $@"IF EXISTS(SELECT name FROM sys.procedures WHERE name LIKE 'spDDI|_RefreshIndexStructures|_ManualScript|_%WasRunOn%' ESCAPE('|')
            AND create_date < DATEADD(DAY, {minAgeInDays}, SYSDATETIME()))
                        BEGIN
                            SELECT CAST(1 AS BIT)
                        END
                        ELSE
                        BEGIN
                            SELECT CAST(0 AS BIT)
                        END";
        }

        public static string DoesErroredOutDDIStoreProcExist(int minAgeInDays)
        {
            return $@"IF EXISTS(SELECT name FROM sys.procedures WHERE name LIKE 'spDDI|_RefreshIndexStructures|_ManualScript|_%ErroredOutOn%' ESCAPE('|')
            AND create_date < DATEADD(DAY, {minAgeInDays}, SYSDATETIME()))
                        BEGIN
                            SELECT CAST(1 AS BIT)
                        END
                        ELSE
                        BEGIN
                            SELECT CAST(0 AS BIT)
                        END";
        }

        public static string DoesNonDDIStoreProcExist()
        {
            return $@"IF EXISTS(SELECT name FROM sys.procedures WHERE name LIKE 'spNonDDI_RefreshIndexStructuresProcedure')
                        BEGIN
                            SELECT CAST(1 AS BIT)
                        END
                        ELSE
                        BEGIN
                            SELECT CAST(0 AS BIT)
                        END";
        }

        public static string DoesTableExist(string tableName)
        {
            return $@"IF EXISTS(SELECT name FROM sys.tables 
                        WHERE name LIKE '{tableName}')
                        BEGIN
                            SELECT CAST(1 AS BIT)
                        END
                        ELSE
                        BEGIN
                            SELECT CAST(0 AS BIT)
                        END";
        }

        public static string ExecuteCleanupOldObjectsSP(int minAgeInDays)
        {
            return $@"EXEC Utility.spDDI_CleanUpOldObjects
                        @Debug = 0,
                        @MinAgeInDays = {minAgeInDays}";
        }
    }
}