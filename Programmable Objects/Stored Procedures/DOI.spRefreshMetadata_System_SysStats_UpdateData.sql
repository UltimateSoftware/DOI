IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStats_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysStats_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysStats_UpdateData]
AS

UPDATE ST
SET ST.column_list = StatsColumnList
--SELECT *
FROM DOI.SysStats ST
    INNER JOIN DOI.SysDatabases d ON d.database_id = ST.database_id
    INNER JOIN DOI.SysTables t ON t.database_id = d.database_id
        AND st.object_id = t.object_id
    INNER JOIN DOI.SysSchemas s ON t.schema_id = s.schema_id
    CROSS APPLY (	SELECT c.name + ',' 
					FROM DOI.SysStatsColumns stc 
						INNER JOIN DOI.SysColumns c ON stc.object_id = c.object_id
							AND stc.column_id = c.column_id
					WHERE stc.object_id = st.object_id 
						AND stc.stats_id = st.stats_id
                    ORDER BY stc.stats_column_id ASC
					FOR XML PATH('')) StatsColumns(StatsColumnList)
GO