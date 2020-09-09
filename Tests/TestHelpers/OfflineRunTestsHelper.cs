using System;
using System.Data.SqlClient;
using TestHelper = DOI.Tests.TestHelpers;

namespace DOI.Tests.TestHelpers
{
    public class OfflineRunTestsHelper
    {
        protected static TestHelper.SqlHelper sqlHelper = new TestHelper.SqlHelper();
        protected DataDrivenIndexTestHelper dataDrivenIndexTestHelper;


        public void UpdateBusinessHours(bool isBusinessHours)
        {
            string sqlCommand = $@"UPDATE DOI.BusinessHoursSchedule SET IsBusinessHours = '{isBusinessHours}'";
            sqlHelper.Execute(sqlCommand);
        }

        public int GetLogErrorCount(string schemaName, string tableName)
        {
            sqlHelper = new TestHelper.SqlHelper();

            int errorsCount = sqlHelper.ExecuteScalar<int>($@"
                SELECT COUNT(*)
                FROM DOI.Log
                WHERE SchemaName = '{schemaName}'
                    AND TableName = '{tableName}'
                    AND ErrorText IS NOT NULL");

            return errorsCount;
        }

        public int GetKillCommandInLogCount(string schemaName, string tableName)
        {
            sqlHelper = new TestHelper.SqlHelper();

            int killLogCount = sqlHelper.ExecuteScalar<int>($@"
                SELECT COUNT(*) 
                FROM DOI.Log 
                WHERE SchemaName = '{schemaName}'
                    AND TableName = '{tableName}'
                    AND IndexOperation = 'Kill'");

            return killLogCount;
        }

        public int OfflineQueueCountForIndex(string schemaName, string tableName, string indexName)
        {
            sqlHelper = new TestHelper.SqlHelper();

            int offlineQueueCountPKOnly = sqlHelper.ExecuteScalar<int>($@"
                SELECT COUNT(*) 
                FROM DOI.Queue
                WHERE SchemaName = '{schemaName}'
                    AND TableName = '{tableName}'
                    AND IndexName = '{indexName}'
                    AND IsOnlineOperation = 0");

            return offlineQueueCountPKOnly;
        }
        
        public int IndexesToUpdateInTableCount(string schemaName, string tableName)
        {
            sqlHelper = new TestHelper.SqlHelper();

            int indexesToUpdateCount = sqlHelper.ExecuteScalar<int>($@"
                SELECT COUNT(*)
                FROM DOI.vwIndexes
                WHERE SchemaName = '{schemaName}'
                    AND TableName = '{tableName}'
                    AND IndexUpdateType <> 'None'");

            return indexesToUpdateCount;
        }

        public int BusinessHoursErrorCount(string schemaName, string tableName)
        {
            sqlHelper = new TestHelper.SqlHelper();

            int businessHoursErrorCount =
                sqlHelper.ExecuteScalar<int>(
                    $@" SELECT COUNT(*) 
                        FROM DOI.Log 
                        WHERE SchemaName = '{schemaName}' 
                            AND TableName = '{tableName}' 
                            AND ErrorText = 'Stopping Offline DOI.  Business hours are here.'");

            return businessHoursErrorCount;
        }

        public string UpdateTypeForIndex(string schemaName, string tableName, string indexName)
        {
            sqlHelper = new TestHelper.SqlHelper();

            string indexUpdateType = sqlHelper.ExecuteScalar<string>($@"
                SELECT IndexUpdateType
                FROM DOI.vwIndexes
                WHERE SchemaName = '{schemaName}'
                    AND TableName = '{tableName}'
                    AND IndexName = '{indexName}'");

            return indexUpdateType;
        }

        public bool IsDelayInProgressInQueue(string schemaName, string tableName)
        {
            sqlHelper = new TestHelper.SqlHelper();

            bool isDelayInProgress = sqlHelper.ExecuteScalar<bool>($@"
                SELECT 1
                FROM DOI.Queue
                WHERE SchemaName = '{schemaName}'
                    AND TableName = '{tableName}'
                    AND IndexOperation = 'Delay'
                    AND InProgress = 1");

            return isDelayInProgress;
        }

        public bool GetApplicationLock()
        {
            sqlHelper = new TestHelper.SqlHelper();

            bool applicationLock = sqlHelper.ExecuteScalar<bool>(@"
                SELECT CAST(CASE WHEN request_session_id IS NOT NULL THEN 1 ELSE 0 END AS BIT)
                FROM   sys.dm_tran_locks
                WHERE  resource_type = 'APPLICATION'
                    AND request_mode = 'X'
                    AND request_status = 'GRANT'
                    AND resource_description LIKE '%:\[\]:%' ESCAPE '\' ");

            return applicationLock;
        }

        //public void InsertDelayInQueue(string schemaName, string tableName, int seqNo, TimeSpan lengthOfDelay)
        //{
        //    sqlHelper = new TestHelper.SqlHelper();

        //    sqlHelper.Execute($@"
        //        EXEC DOI.spInsertDelay
        //            @ParentTableName = '{tableName}',
        //            @ParentSchemaName = '{schemaName}',
        //            @SeqNoJustAfterDelay = {seqNo},
        //            @LengthOfDelay = '{lengthOfDelay}'");
        //}


        public void InsertDelayInQueue(string schemaName, string tableName, int seqNo, TimeSpan lengthOfDelay)
        {
            var sql = $" WAITFOR DELAY '{lengthOfDelay.ToString()}' ";
            this.InsertSqlCommandInQueue(schemaName, tableName, seqNo, sql);
        }

        public void InsertSqlCommandInQueue(string schemaName, string tableName, int seqNo, string sql)
        {
            sqlHelper = new TestHelper.SqlHelper();
            SqlCommand command = new SqlCommand(@"EXEC DOI.spInsertSQLCommand
                                                    @ParentTableName = @table,
                                                    @ParentSchemaName = @schema,
                                                    @SeqNoJustAfterSQLCommand = @seq,
                                                    @SQLCommand = @sql");

            command.Parameters.AddWithValue("@table", tableName);
            command.Parameters.AddWithValue("@schema", schemaName);
            command.Parameters.AddWithValue("@seq", seqNo);
            command.Parameters.AddWithValue("@sql", sql);

            sqlHelper.Execute(command);
        }

        public static int GetSeqNoForIndexOperationSql(string indexOperation)
        {
            return new TestHelper.SqlHelper().ExecuteScalar<int>($@"
                        SELECT SeqNo
                        FROM DOI.Queue 
                        WHERE SchemaName = 'dbo' 
                            AND TableName = 'TempA'
                            AND IndexOperation = '{indexOperation}'");
        }

        public static readonly string SeqNoForIndexOperationSql = @"
                        SELECT SeqNo
                        FROM DOI.Queue 
                        WHERE SchemaName = 'dbo' 
                            AND TableName = 'TempA'
                            AND IndexOperation = 'Create Index'";

        public static readonly string IndexInsertSql =
            @"UPDATE DOI.IndexesRowStore SET KeyColumnList = 'TempAId ASC,TransactionUtcDt ASC' 
                WHERE SchemaName = 'dbo' 
                    AND TableName = 'TempA '
                    AND IndexName = 'PK_TempA'";

        public static string IntroduceNonTransactionalChange = $@"
                UPDATE DOI.IndexesColumnStore 
                SET OptionDataCompression = 'COLUMNSTORE_ARCHIVE' 
                WHERE SchemaName = 'dbo' 
                    AND TableName = 'TempA' 
                    AND IndexName = 'NCCI_TempA'";


        public static readonly string SetToBusinessHoursSql = "UPDATE DOI.BusinessHoursSchedule SET IsBusinessHours = 1";

        public static readonly string SetToNonBusinessHoursSql = "UPDATE DOI.BusinessHoursSchedule SET IsBusinessHours = 0";


        public static int GetOfflineQueueCountPKOnly()
        {
            return new TestHelper.SqlHelper().ExecuteScalar<int>(@"SELECT COUNT(*) 
            FROM DOI.Queue
            WHERE SchemaName = 'dbo'
            AND TableName = 'TempA'
            AND IndexName = 'PK_TempA'");
        }

        public static int GetOfflineQueueCountNCCIOnly()
        {
            return new TestHelper.SqlHelper().ExecuteScalar<int>(@"
            SELECT COUNT(*) 
            FROM DOI.Queue
            WHERE SchemaName = 'dbo'
            AND TableName = 'TempA'
            AND IndexName = 'NCCI_TempA'");
        }


        public static int GetOfflineQueueCountSQL()
        {
            return sqlHelper.ExecuteScalar<int>(
                @"  SELECT COUNT(*) 
                    FROM DOI.Queue 
                    WHERE SchemaName = 'dbo' AND TableName = 'TempA' AND IsOnlineOperation = 0");
        }
    }
}
