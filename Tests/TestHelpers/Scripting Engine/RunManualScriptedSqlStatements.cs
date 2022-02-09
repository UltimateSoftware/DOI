

namespace DOI.Tests.TestHelpers.Scripting_Engine
{
    public static class RunManualScriptedSqlStatements
    {
        public static string CreateSP(string mode)
        {
            return $@"CREATE PROCEDURE [Utility].[spDDI_RefreshIndexStructures_ManualScript_{mode}_SomeDate]
                        AS
                        SELECT 'TEST' as Test";
        }

        public static string CreateFailingSP(string mode)
        {
            return $@"CREATE PROCEDURE [Utility].[spDDI_RefreshIndexStructures_ManualScript_{mode}_SomeDate]
                        AS
                        SELECT 'TEST' as Test;
                        THROW 50000, 'Making this SP fail on purpose.', 1";
        }

        public static string DDIStoreProcCount(string mode)
        {
            return $@"SELECT COUNT(*) FROM sys.procedures WHERE name LIKE '%spDDI|_RefreshIndexStructures|_ManualScript|_{mode}|_SomeDate%' ESCAPE('|')";
        }

        public static string DoesDDIStoreProcExist(string mode, string resultLabel)
        {
            return $@"IF EXISTS(SELECT name FROM sys.procedures WHERE name LIKE '%spDDI|_RefreshIndexStructures|_ManualScript|_{mode}|_SomeDate|_{resultLabel}%' ESCAPE('|'))
                        BEGIN
                            SELECT CAST(1 AS BIT)
                        END
                        ELSE
                        BEGIN
                            SELECT CAST(0 AS BIT)
                        END";
        }

        public static string ExecuteRunManualScriptedSP(int onlineOperation)
        {
            return $@"EXEC Utility.spDDI_RefreshIndexStructures_RunManualScripted
                        @OnlineOperations = {onlineOperation},
                        @Debug = 0";
        }
    }
}