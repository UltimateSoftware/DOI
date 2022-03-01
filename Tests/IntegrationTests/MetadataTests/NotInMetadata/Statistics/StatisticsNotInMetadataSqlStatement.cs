using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.MetadataTests.NotInMetadata.Constraints
{
    public static class StatisticNotInMetadataSqlStatements
    {
        public const string DatabaseName = "DOIUnitTests";

        public static string CreateSqlServerStatistic(string statisticName)
        {
            return $@"CREATE STATISTICS {statisticName} ON dbo.TempA (TransactionUtcDt)";
        }

        public static string CreateSqlServerStatisticWithMultipleColumns(string statisticName)
        {
            return $@"CREATE STATISTICS {statisticName} ON dbo.TempA (TransactionUtcDt, TextCol)";
        }

        public static string InsertStatisticInMetadata(string statisticName)
        {
            return $@"INSERT INTO DOI.[Statistics]
                (
                     DatabaseName
	                ,SchemaName
	                ,TableName
	                ,StatisticsName
	                ,StatisticsColumnList_Desired
	                ,SampleSizePct_Desired
	                ,IsFiltered_Desired
	                ,FilterPredicate_Desired
	                ,IsIncremental_Desired
	                ,NoRecompute_Desired
	                ,LowerSampleSizeToDesired
	                ,ReadyToQueue
                )
                VALUES 
                (
                    '{DatabaseName}'
	                ,'dbo'
	                ,'TempA'
	                ,'{statisticName}'
	                ,'TransactionUtcDt'
	                ,20
	                ,0
	                ,NULL
	                ,0
	                ,0
	                ,0
	                ,1
                )";
        }

        public static string DropStatisticSql(string statisticName)
        {
            return $@"DROP STATISTICS dbo.TempA.{statisticName}";
        }

        public static string DeleteStatisticMetadataSql(string statisticName)
        {
            return $@"DELETE DOI.[Statistics] WHERE DatabaseName = '{DatabaseName}' AND SchemaName = 'dbo' AND TableName = 'TempA' AND StatisticsName = '{statisticName}'";
        }


        public static string DoesStatisticsExistInMetadataTable(string statisticName)
        {
            return $@"IF EXISTS(SELECT 'True' FROM DOI.[Statistics] WHERE DatabaseName = '{DatabaseName}' AND SchemaName = 'dbo' AND TableName = 'TempA' AND StatisticsName = '{statisticName}')
                BEGIN
                    SELECT CAST(1 AS BIT)
                END
                ELSE
                BEGIN
                    SELECT CAST(0 AS BIT)
                END";
        }

        public static string MetadataTableStatisticsColumnList(string statisticName)
        {
            return $@"SELECT StatisticsColumnList_Desired FROM DOI.[Statistics] WHERE DatabaseName = '{DatabaseName}' AND SchemaName = 'dbo' AND TableName = 'TempA'  AND StatisticsName = '{statisticName}'";
        }

        public static string MetadataTableStatisticsCount(string statisticName)
        {
            return $@"SELECT COUNT(*) FROM DOI.[Statistics] WHERE DatabaseName = '{DatabaseName}' AND SchemaName = 'dbo' AND TableName = 'TempA' AND StatisticsName = '{statisticName}'";
        }
        
        public static string StatisticCount(string statisticName)
        {
            return $@"SELECT COUNT(*) FROM DOI.[Statistics] WHERE DatabaseName = '{DatabaseName}' AND SchemaName = 'dbo' AND TableName = 'TempA' AND StatisticsName = '{statisticName}'";
        }
    }
}
