using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.MetadataTests.NotInMetadata.Indexes
{
    public static class IndexNotInMetadataSqlStatement
    {
        private const string DatabaseName = "DOIUnitTests";

		public static string CreateSqlServerRowStoreIndex =
			@"CREATE NONCLUSTERED INDEX IDX_TempA_TransactionUtcDt ON dbo.TempA(TransactionUtcDt)";

		public static string CreateSqlServerColumnStoreIndex =
			@"CREATE NONCLUSTERED COLUMNSTORE INDEX IDX_TempA_TransactionUtcDt ON dbo.TempA(TransactionUtcDt)";

		public static string DoesIndexExistInNotInMetadataTableSql =
			@"IF EXISTS(SELECT 'True' FROM DOI.IndexesNotInMetadata WHERE SchemaName = 'dbo' AND TableName = 'TempA' AND IndexName = 'IDX_TempA_TransactionUtcDt')
                BEGIN
                    SELECT CAST(1 AS BIT)
                END
                ELSE
                BEGIN
                    SELECT CAST(0 AS BIT)
                END";

		public static string InsertRecordInIndexNotInMetadataTable =
			@"INSERT INTO DOI.IndexesNotInMetadata 
                (
	                 SchemaName
	                ,TableName
	                ,IndexName
	                ,DropSQLScript
                ) 
                VALUES
                (
	                 'dbo'
	                ,'TempA'
	                ,'IDX_TempA_TransactionUtcDt'
	                ,'DROP INDEX dbo.TempA.IDX_TempA_TransactionUtcDt'
                )";

		public static string InsertRowIndexInMetadata =
			$@"INSERT INTO DOI.IndexesRowStore 
	            (	
                     DatabaseName
		            ,SchemaName
		            ,TableName
		            ,IndexName
		            ,IsUnique_Desired
		            ,IsPrimaryKey_Desired
		            ,IsUniqueConstraint_Desired
		            ,IsClustered_Desired
		            ,KeyColumnList_Desired
		            ,IncludedColumnList_Desired
		            ,IsFiltered_Desired
                    ,FilterPredicate_Desired
		            ,[Fillfactor_Desired]
		            ,OptionPadIndex_Desired
		            ,OptionStatisticsNoRecompute_Desired
		            ,OptionStatisticsIncremental_Desired
		            ,OptionIgnoreDupKey_Desired
		            ,OptionResumable_Desired
		            ,OptionMaxDuration_Desired
		            ,OptionAllowRowLocks_Desired
		            ,OptionAllowPageLocks_Desired
		            ,OptionDataCompression_Desired
		            ,Storage_Desired
		            ,PartitionColumn_Desired
	            )
                VALUES	 
	            (	
                      N'{DatabaseName}'
		            , N'dbo'
		            , N'TempA'
		            , N'IDX_TempA_TransactionUtcDt'
		            , 0
		            , 0
		            , 0
		            , 0
		            , N'TempAId'
		            , NULL
		            , 0
		            , NULL
		            , 0
		            , 1
		            , 0
		            , 0
		            , 0
		            , DEFAULT
		            , 0
		            , 1
		            , 1
		            , 'PAGE'
		            , 'PRIMARY'
		            , NULL
	            )";

		public static string InsertColumnIndexInMetadata =
			$@"INSERT INTO DOI.IndexesColumnStore
                (
	                 DatabaseName
		            ,SchemaName
	                ,TableName
	                ,IndexName
	                ,IsClustered_Desired
	                ,ColumnList_Desired
	                ,IsFiltered_Desired
	                ,FilterPredicate_Desired
	                ,OptionDataCompression_Desired
	                ,OptionDataCompressionDelay_Desired
	                ,Storage_Desired
	                ,PartitionColumn_Desired
                )
                VALUES 
                (
	                 N'{DatabaseName}'
		            ,N'dbo'
	                ,N'TempA'
	                ,'IDX_TempA_TransactionUtcDt'
	                ,0
	                ,NULL
	                ,0
	                ,NULL
	                ,'COLUMNSTORE'
	                ,0
	                ,'PRIMARY'
	                ,NULL
                )";
    }
}
