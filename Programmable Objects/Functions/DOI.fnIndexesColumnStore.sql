IF OBJECT_ID('[DOI].[fnIndexesColumnStore]') IS NOT NULL
	DROP FUNCTION [DOI].[fnIndexesColumnStore];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [DOI].[fnIndexesColumnStore]()

RETURNS TABLE
WITH NATIVE_COMPILATION, SCHEMABINDING 

AS

/*
    select * from DOI.fnIndexesColumnStore()
*/

RETURN(
            SELECT	 ICS.DatabaseName
                    ,ICS.SchemaName 
				    ,ICS.TableName
				    ,ICS.IndexName
                    ,ICS.IsIndexMissingFromSQLServer
				    ,NULL AS IsUnique_Desired
                    ,NULL AS IsUnique_Actual
                    ,NULL AS IsPrimaryKey_Desired
                    ,NULL AS IsPrimaryKey_Actual
                    ,NULL AS IsUniqueConstraint_Desired
                    ,NULL AS IsUniqueConstraint_Actual
                    ,ICS.IsClustered_Desired
				    ,ICS.IsClustered_Actual
				    ,ICS.ColumnList_Desired AS KeyColumnList_Desired
				    ,ICS.ColumnList_Actual AS KeyColumnList_Actual
					,CAST(NULL AS VARCHAR(MAX)) AS IncludedColumnList_Desired
					,CAST(NULL AS VARCHAR(MAX)) AS IncludedColumnList_Actual
				    ,ICS.IsFiltered_Desired
				    ,ICS.IsFiltered_Actual
				    ,ICS.FilterPredicate_Desired
				    ,ICS.FilterPredicate_Actual
					,NULL AS Fillfactor_Desired
					,NULL AS Fillfactor_Actual
					,NULL AS OptionPadIndex_Desired
					,NULL AS OptionPadIndex_Actual
					,NULL AS OptionStatisticsNoRecompute_Desired
					,NULL AS OptionStatisticsNoRecompute_Actual
					,NULL AS OptionStatisticsIncremental_Desired
					,NULL AS OptionStatisticsIncremental_Actual
					,NULL AS OptionIgnoreDupKey_Desired
					,NULL AS OptionIgnoreDupKey_Actual
				    ,ICS.OptionDataCompression_Desired
				    ,ICS.OptionDataCompression_Actual
				    ,ICS.OptionDataCompressionDelay_Desired
				    ,ICS.OptionDataCompressionDelay_Actual
					,NULL AS OptionAllowRowLocks_Desired
					,NULL AS OptionAllowRowLocks_Actual
					,NULL AS OptionAllowPageLocks_Desired
					,NULL AS OptionAllowPageLocks_Actual
					,NULL AS OptionResumable_Desired
--					,ICS.OptionResumable_Actual
--					,ICS.OptionMaxDuration_Desired
					,NULL AS OptionMaxDuration_Actual
					,ICS.PartitionFunction_Desired
					,ICS.PartitionFunction_Actual
				    ,ICS.Storage_Desired
				    ,ICS.Storage_Actual
				    ,ICS.IsStorageChanging
				    ,ICS.StorageType_Desired
				    ,ICS.StorageType_Actual
				    ,ICS.PartitionColumn_Desired
                    ,ICS.IndexSizeMB_Actual
				    ,ICS.Fragmentation
				    ,TTP.IntendToPartition
				    ,ICS.NeedsPartitionLevelOperations
                    ,ICS.TotalPartitionsInIndex
				    ,ICS.IndexMeetsMinimumSize
				    ,ICS.FragmentationType
				    ,ICS.AreDropRecreateOptionsChanging
				    ,ICS.AreRebuildOptionsChanging
				    ,ICS.AreRebuildOnlyOptionsChanging
				    ,ICS.AreReorgOptionsChanging
				    ,ICS.AreSetOptionsChanging
				    ,0 AS IsUniquenessChanging
				    ,0 AS IsPrimaryKeyChanging
				    ,ICS.IsColumnListChanging AS IsKeyColumnListChanging
				    ,0 AS IsIncludedColumnListChanging
				    ,ICS.IsFilterChanging
				    ,ICS.IsClusteredChanging
				    ,ICS.IsPartitioningChanging
				    ,0 AS IsPadIndexChanging
				    ,0 AS IsFillfactorChanging
				    ,0 AS IsIgnoreDupKeyChanging
				    ,0 AS IsStatisticsNoRecomputeChanging
				    ,0 AS IsStatisticsIncrementalChanging
				    ,0 AS IsAllowRowLocksChanging
				    ,0 AS IsAllowPageLocksChanging
				    ,ICS.IsDataCompressionChanging
				    ,ICS.IsDataCompressionDelayChanging
				    ,0 AS IndexHasLOBColumns
				    ,ICS.NumPages_Actual
                    ,'ColumnStore' AS IndexType
                    ,ICS.IsIndexLarge
                    ,ICS.DriveLetter
			FROM DOI.Tables TTP
                INNER JOIN DOI.SysDatabases d on d.name = TTP.DatabaseName
				INNER JOIN DOI.IndexesColumnStore ICS ON TTP.SchemaName = ICS.SchemaName
					AND TTP.TableName = ICS.TableName
        )

























































































GO
