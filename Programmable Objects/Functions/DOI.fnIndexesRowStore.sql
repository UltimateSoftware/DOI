-- <Migration ID="b010f08f-8a2e-4bd4-bd6f-73dac7150910" />
GO
-- <Migration ID="11c143d9-29c7-421b-9038-5793f63cf735" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!
IF OBJECT_ID('[DOI].[fnIndexesRowStore]') IS NOT NULL
	DROP FUNCTION [DOI].[fnIndexesRowStore];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [DOI].[fnIndexesRowStore]()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING 
 
AS   

/*
    SELECT * FROM DOI.fnIndexesRowStore()
*/

RETURN  (
            SELECT	IRS.DatabaseName
                    ,IRS.SchemaName 
					,IRS.TableName
					,IRS.IndexName
                    ,IRS.IsIndexMissingFromSQLServer
					,IRS.IsUnique_Desired
					,IRS.IsUnique_Actual
					,IRS.IsPrimaryKey_Desired
					,IRS.IsPrimaryKey_Actual
					,IRS.IsUniqueConstraint_Desired
					,IRS.IsUniqueConstraint_Actual
					,IRS.IsClustered_Desired
					,IRS.IsClustered_Actual
					,IRS.KeyColumnList_Desired
					,IRS.KeyColumnList_Actual
					,IRS.IncludedColumnList_Desired
					,IRS.IncludedColumnList_Actual
					,IRS.IsFiltered_Desired
					,IRS.IsFiltered_Actual
					,IRS.FilterPredicate_Desired
					,IRS.FilterPredicate_Actual
					,IRS.Fillfactor_Desired
					,IRS.Fillfactor_Actual
					,IRS.OptionPadIndex_Desired
					,IRS.OptionPadIndex_Actual
					,IRS.OptionStatisticsNoRecompute_Desired
					,IRS.OptionStatisticsNoRecompute_Actual
					,IRS.OptionStatisticsIncremental_Desired
					,IRS.OptionStatisticsIncremental_Actual
					,IRS.OptionIgnoreDupKey_Desired
					,IRS.OptionIgnoreDupKey_Actual
					,IRS.OptionDataCompression_Desired
					,IRS.OptionDataCompression_Actual
					,NULL AS OptionDataCompressionDelay_Desired
					,NULL AS OptionDataCompressionDelay_Actual
					,IRS.OptionAllowRowLocks_Desired
					,IRS.OptionAllowRowLocks_Actual
					,IRS.OptionAllowPageLocks_Desired
					,IRS.OptionAllowPageLocks_Actual
					,IRS.OptionResumable_Desired
--					,IRS.OptionResumable_Actual
--					,IRS.OptionMaxDuration_Desired
					,IRS.OptionMaxDuration_Actual
					,IRS.PartitionFunction_Desired
					,IRS.PartitionFunction_Actual
					,IRS.Storage_Desired
					,IRS.Storage_Actual
					,IRS.IsStorageChanging
					,IRS.StorageType_Desired
					,IRS.StorageType_Actual
					,IRS.PartitionColumn_Desired
                    ,IRS.IndexSizeMB_Actual
					,IRS.Fragmentation
					,TTP.IntendToPartition
					,IRS.NeedsPartitionLevelOperations
                    ,IRS.TotalPartitionsInIndex
					,IRS.IndexMeetsMinimumSize
					,IRS.FragmentationType
					,IRS.AreDropRecreateOptionsChanging
					,IRS.AreRebuildOptionsChanging
					,IRS.AreRebuildOnlyOptionsChanging
					,IRS.AreReorgOptionsChanging
					,IRS.AreSetOptionsChanging
					,IRS.IsUniquenessChanging
					,IRS.IsPrimaryKeyChanging
					,IRS.IsKeyColumnListChanging
					,IRS.IsIncludedColumnListChanging
					,IRS.IsFilterChanging
					,IRS.IsClusteredChanging
					,IRS.IsPartitioningChanging
					,IRS.IsPadIndexChanging
					,IRS.IsFillfactorChanging
					,IRS.IsIgnoreDupKeyChanging
					,IRS.IsStatisticsNoRecomputeChanging
					,IRS.IsStatisticsIncrementalChanging --if the table is partitioned, ignore this check.
					,IRS.IsAllowRowLocksChanging
					,IRS.IsAllowPageLocksChanging
					,IRS.IsDataCompressionChanging
					,0 AS IsDataCompressionDelayChanging
					,IRS.IndexHasLOBColumns
					,IRS.NumPages_Actual
                    ,'RowStore' AS IndexType
                    ,IRS.IsIndexLarge
                    ,IRS.DriveLetter
			FROM DOI.Tables TTP
                INNER JOIN DOI.SysDatabases d on d.name = TTP.DatabaseName
				INNER JOIN DOI.IndexesRowStore IRS ON TTP.DatabaseName = IRS.DatabaseName
                    AND TTP.SchemaName = IRS.SchemaName
					AND TTP.TableName = IRS.TableName
        )

GO