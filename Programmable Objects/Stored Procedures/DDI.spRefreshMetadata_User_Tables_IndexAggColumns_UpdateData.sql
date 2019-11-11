IF OBJECT_ID('[DDI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [DDI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]
AS

UPDATE T
SET Storage_Actual = IndexAgg.ExistingTableStorage,
    StorageType_Actual = IndexAgg.ExistingTableStorageType,
    StorageType_Desired = IndexAgg.NewTableStorageType, 
    AreIndexesFragmented =  CASE 
			                    WHEN IndexAgg.FragmentationType = 'None'
			                    THEN 0
			                    ELSE 1 
		                    END,
	AreIndexesBeingUpdated =    CASE IndexAgg.AreIndexesBeingUpdated
			                        WHEN 'None'
			                        THEN 0
			                        ELSE 1
		                        END,
	AreIndexesMissing = IndexAgg.AreIndexesMissing,
    IsClusteredIndexBeingDropped = ISNULL(IndexAgg.IsClusteredIndexBeingDropped, 0),
	WhichUniqueConstraintIsBeingDropped =   CASE
		                                        WHEN ISNULL(IndexAgg.IsPKDropped, 0) = 1 AND ISNULL(IndexAgg.IsUQDropped, 0) = 0
		                                        THEN 'PK' 
		                                        WHEN ISNULL(IndexAgg.IsPKDropped, 0) = 0 AND ISNULL(IndexAgg.IsUQDropped, 0) = 1
		                                        THEN 'UQ'
		                                        WHEN ISNULL(IndexAgg.IsPKDropped, 0) = 1 AND ISNULL(IndexAgg.IsUQDropped, 0) = 1
		                                        THEN 'Both'
		                                        ELSE 'None'
	                                        END,
	IsStorageChanging = IndexAgg.IsStorageChanging,
	NeedsTransaction = HasIndexDropAndRecreate,
    PKColumnList = DDI.fnGetPKColumnListForTable (T.DatabaseName, T.SchemaName, T.TableName),
    PKColumnListJoinClause = DDI.fnGetJoinClauseForTable(T.DatabaseName, T.SchemaName, T.TableName, 0, 'T', 'PT')
FROM DDI.Tables T
    INNER JOIN (
                SELECT  I.DatabaseName,
                        I.SchemaName,
                        I.TableName,
                        MIN(I.IndexUpdateType) AS AreIndexesBeingUpdated,
                        MIN(CASE 
								WHEN NumPages_Actual > SS.MinNumPages AND Fragmentation > 30 
								THEN 'Heavy' 
								WHEN NumPages_Actual > SS.MinNumPages AND Fragmentation BETWEEN 5 AND 30 THEN 'Light' 
								ELSE 'None' 
							END) AS FragmentationType,
                        MAX(CAST(I.IsStorageChanging AS TINYINT)) AS IsStorageChanging,
                        MAX(CAST(I.IsIndexMissingFromSQLServer AS TINYINT)) AS AreIndexesMissing,
                        MAX(CASE 
                                WHEN IsClustered_Desired = 1 
                                THEN I.Storage_Actual
                                ELSE '' 
                            END) AS ExistingTableStorage,
                        MAX(CASE 
                                WHEN IsClustered_Desired = 1 
                                THEN I.StorageType_Actual
                                ELSE '' 
                            END) AS ExistingTableStorageType,
                        MAX(CASE 
                                WHEN IsClustered_Desired = 1 
                                THEN I.StorageType_Desired
                                ELSE '' 
                            END) AS NewTableStorageType,
                        MAX(CASE 
                                WHEN IsClustered_Desired = 1 
                                    AND (IsUnique_Desired <> ISNULL(IsUnique_Actual, '') 
							                OR KeyColumnList_Desired <>ISNULL(KeyColumnList_Actual, '') 
							                OR ISNULL(IncludedColumnList_Desired, '') <> ISNULL(IncludedColumnList_Actual, '') 
							                OR ISNULL(FilterPredicate_Desired, '') <> ISNULL(FilterPredicate_Actual, '') 
							                OR IsClustered_Desired <> IsClustered_Actual
							                OR (PartitionFunction_Desired <> PartitionFunction_Actual
								                AND TTP.IntendToPartition = 1))
                                THEN 1
                                ELSE 0
                            END) AS IsClusteredIndexBeingDropped,
                        MAX(CASE 
				                WHEN (IsUnique_Desired <> ISNULL(IsUnique_Actual, '') 
						                OR KeyColumnList_Desired <>ISNULL(KeyColumnList_Actual, '') 
						                OR ISNULL(IncludedColumnList_Desired, '') <> ISNULL(IncludedColumnList_Actual, '') 
						                OR ISNULL(FilterPredicate_Desired, '') <> ISNULL(FilterPredicate_Actual, '') 
						                OR IsClustered_Desired <> IsClustered_Actual
						                OR (PartitionFunction_Desired <> PartitionFunction_Actual
							                AND TTP.IntendToPartition = 1))
				                THEN 1 
				                ELSE 0 
			                END) AS HasIndexDropAndRecreate, --this is the same logic as AreDropRecreateOptionsChanging
                        MAX(CASE
                                WHEN (IsPrimaryKey_Desired = 1 AND IsUnique_Desired = 1)
                                    AND (IsUnique_Desired <> ISNULL(IsUnique_Actual, '') 
						                OR KeyColumnList_Desired <>ISNULL(KeyColumnList_Actual, '') 
						                OR ISNULL(IncludedColumnList_Desired, '') <> ISNULL(IncludedColumnList_Actual, '') 
						                OR ISNULL(FilterPredicate_Desired, '') <> ISNULL(FilterPredicate_Actual, '') 
						                OR IsClustered_Desired <> IsClustered_Actual
						                OR (PartitionFunction_Desired <> PartitionFunction_Actual
							                AND TTP.IntendToPartition = 1)) --this is the same logic as AreDropRecreateOptionsChanging
                                THEN 1
                                ELSE 0
                            END) AS IsPKDropped, 
                        MAX(CASE
                                WHEN (IsPrimaryKey_Desired = 0 AND IsUnique_Desired = 1)
                                    AND (IsUnique_Desired <> ISNULL(IsUnique_Actual, '') 
						                OR KeyColumnList_Desired <>ISNULL(KeyColumnList_Actual, '') 
						                OR ISNULL(IncludedColumnList_Desired, '') <> ISNULL(IncludedColumnList_Actual, '') 
						                OR ISNULL(FilterPredicate_Desired, '') <> ISNULL(FilterPredicate_Actual, '') 
						                OR IsClustered_Desired <> IsClustered_Actual
						                OR (PartitionFunction_Desired <> PartitionFunction_Actual
							                AND TTP.IntendToPartition = 1)) --this is the same logic as AreDropRecreateOptionsChanging
                                THEN 1
                                ELSE 0
                            END) AS IsUQDropped

                from DDI.vwIndexes I
                    INNER JOIN DDI.Tables TTP ON TTP.DatabaseName = I.DatabaseName
                        AND TTP.SchemaName = I.SchemaName
                        AND TTP.TableName = I.TableName
                    CROSS JOIN (SELECT CAST(SettingValue AS INT) AS MinNumPages FROM DDI.SystemSettings WHERE SettingName = 'MinNumPagesForIndexDefrag') SS
                GROUP BY I.DatabaseName, I.SchemaName, I.TableName ) IndexAgg
        ON IndexAgg.DatabaseName = T.DatabaseName
            AND IndexAgg.SchemaName = T.SchemaName
            AND IndexAgg.TableName = T.TableName


UPDATE T
SET AreStatisticsChanging = ISNULL(StatsAgg.AreStatisticsChanging, 0)
FROM DDI.Tables T
    OUTER APPLY(SELECT	1 AS AreStatisticsChanging
				FROM DDI.[Statistics] STM
				WHERE STM.DatabaseName = T.DatabaseName
                    AND STM.SchemaName = T.SchemaName
					AND STM.TableName = T.TableName
                    AND STM.ReadyToQueue = 1
					AND STM.StatisticsUpdateType <> 'None'
				GROUP BY STM.SchemaName, STM.TableName) StatsAgg

GO
