
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysIndexes_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexes_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysIndexes_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysIndexes_UpdateData]
        @DatabaseName = 'DOIUnitTests'
*/

UPDATE T
SET fill_factor = CASE WHEN fill_factor = 0 THEN 100 ELSE fill_factor END
FROM DOI.SysIndexes T 
    INNER JOIN DOI.SysDatabases D ON D.database_id = T.database_id
WHERE d.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

UPDATE T
SET key_column_list = y.IndexKeyColumnList
from DOI.SysIndexes T 
    INNER JOIN DOI.SysDatabases D ON D.database_id = T.database_id
    INNER JOIN (SELECT database_id, object_id, index_id, STUFF(IndexKeyColumnList,LEN(X.IndexKeyColumnList),1,'') AS IndexKeyColumnList
                FROM DOI.SysIndexes T
                    CROSS APPLY (   SELECT C.NAME + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END + ','
                                    FROM DOI.SysIndexColumns ic 
                                        INNER JOIN DOI.SysColumns C ON C.column_id = ic.column_id
                                            AND C.object_id = ic.OBJECT_ID
                                            AND c.database_id = ic.database_id
                                    WHERE T.database_id = IC.database_id
                                        AND T.object_id = IC.object_id
                                        AND T.index_id = IC.index_id
                                        AND ic.is_included_column = 0
	                                    AND ic.key_ordinal > 0
                                    ORDER BY ic.key_ordinal
                                    FOR XML PATH('')) x(IndexKeyColumnList)) y
        ON T.database_id = y.database_id
            and T.object_id = y.object_id
            and T.index_id = y.index_id
WHERE d.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


UPDATE T
SET included_column_list = y.IndexIncludedColumnList
FROM DOI.SysIndexes T 
    INNER JOIN DOI.SysDatabases D ON D.database_id = T.database_id
    INNER JOIN (SELECT database_id, object_id, index_id, STUFF(IndexIncludedColumnList,LEN(X.IndexIncludedColumnList),1,'') AS IndexIncludedColumnList
                FROM DOI.SysIndexes T
                    CROSS APPLY (   SELECT C.NAME + ','
                                    FROM DOI.SysIndexColumns ic 
                                        INNER JOIN DOI.SysColumns C ON C.column_id = ic.column_id
                                            AND C.object_id = ic.OBJECT_ID
                                            AND c.database_id = ic.database_id
                                    WHERE T.database_id = IC.database_id
                                        AND T.object_id = IC.object_id
                                        AND T.index_id = IC.index_id
                                        AND ic.is_included_column = 1
										AND ic.key_ordinal = 0
										AND ic.partition_ordinal = 0
                                    ORDER BY ic.key_ordinal
                                    FOR XML PATH('')) x(IndexIncludedColumnList)) y
        ON T.database_id = y.database_id
            and T.object_id = y.object_id
            and T.index_id = y.index_id
WHERE d.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


UPDATE T
SET has_LOB_columns = ISNULL(IndexHasLOBColumns, 0)
FROM DOI.SysIndexes T 
    INNER JOIN DOI.SysDatabases D ON D.database_id = T.database_id
	OUTER APPLY (	SELECT 1 AS IndexHasLOBColumns 
					FROM DOI.SysIndexColumns ic
						INNER JOIN DOI.SysColumns c ON c.object_id = ic.object_id
							AND c.column_id = ic.column_id
                            AND c.database_id = ic.database_id
						INNER JOIN DOI.SysTypes ty ON c.database_id = ty.database_id
                            AND c.user_type_id = ty.user_type_id
					WHERE ic.database_id = T.database_id
                        AND ic.object_id = T.object_id	
						AND ic.index_id = T.index_id
						AND ty.is_user_defined = 0
						AND (ty.name IN ('image', 'text', 'ntext') --not supported for online index rebuilds
							OR c.max_length = -1)) LOBColumns
WHERE d.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


GO
