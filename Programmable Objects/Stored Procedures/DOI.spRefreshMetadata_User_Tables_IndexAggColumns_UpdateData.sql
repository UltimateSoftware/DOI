
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [DOI].[spRefreshMetadata_User_Tables_IndexAggColumns_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

AS

UPDATE T
SET AreIndexesFragmented =  CASE 
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
    PKColumnList = DOI.fnGetPKColumnListForTable (T.DatabaseName, T.SchemaName, T.TableName),
    PKColumnListJoinClause = DOI.fnGetJoinClauseForTable(T.DatabaseName, T.SchemaName, T.TableName, 0, 'T', 'PT')
FROM DOI.Tables T
    INNER JOIN (
                SELECT  I.DatabaseName,
                        I.SchemaName,
                        I.TableName,
                        MIN(I.IndexUpdateType) AS AreIndexesBeingUpdated,
                        MIN(I.FragmentationType) AS FragmentationType,
                        MAX(CAST(I.IsStorageChanging AS TINYINT)) AS IsStorageChanging,
                        MAX(CAST(I.IsIndexMissingFromSQLServer AS TINYINT)) AS AreIndexesMissing,
                        MAX(CASE 
                                WHEN I.IsClustered_Actual = 1
                                    AND AreDropRecreateOptionsChanging = 1
                                THEN 1
                                ELSE 0
                            END) AS IsClusteredIndexBeingDropped,
                        MAX(CASE
                                WHEN IsPrimaryKey_Actual = 1 
									AND IsUnique_Actual = 1
                                    AND AreDropRecreateOptionsChanging = 1
                                THEN 1
                                ELSE 0
                            END) AS IsPKDropped, 
                        MAX(CASE
                                WHEN IsPrimaryKey_Actual = 0 
									AND IsUnique_Actual = 1
                                    AND AreDropRecreateOptionsChanging = 1
                                THEN 1
                                ELSE 0
                            END) AS IsUQDropped
                FROM DOI.vwIndexes I --we should not be using the view here...circular reference?  But we need IndexUpdateType, which is calculated in the view.
                    INNER JOIN DOI.Tables TTP ON TTP.DatabaseName = I.DatabaseName
                        AND TTP.SchemaName = I.SchemaName
                        AND TTP.TableName = I.TableName
                    CROSS JOIN (SELECT CAST(SettingValue AS INT) AS MinNumPages FROM DOI.DOISettings WHERE SettingName = 'MinNumPagesForIndexDefrag') SS
                GROUP BY I.DatabaseName, I.SchemaName, I.TableName ) IndexAgg
        ON IndexAgg.DatabaseName = T.DatabaseName
            AND IndexAgg.SchemaName = T.SchemaName
            AND IndexAgg.TableName = T.TableName
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 


UPDATE T
SET AreStatisticsChanging = ISNULL(StatsAgg.AreStatisticsChanging, 0)
FROM DOI.Tables T
    OUTER APPLY(SELECT	1 AS AreStatisticsChanging
				FROM DOI.[Statistics] STM
				WHERE STM.DatabaseName = T.DatabaseName
                    AND STM.SchemaName = T.SchemaName
					AND STM.TableName = T.TableName
                    AND STM.ReadyToQueue = 1
					AND STM.StatisticsUpdateType <> 'None'
				GROUP BY STM.SchemaName, STM.TableName) StatsAgg
WHERE T.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN T.DatabaseName ELSE @DatabaseName END 

GO
