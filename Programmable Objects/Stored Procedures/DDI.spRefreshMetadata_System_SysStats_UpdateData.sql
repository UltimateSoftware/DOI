IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysStats_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysStats_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysStats_UpdateData]
AS

UPDATE ST
SET ST.column_list = StatsColumnList
--SELECT *
FROM DDI.SysStats ST
    INNER JOIN DDI.SysDatabases d ON d.database_id = ST.database_id
    INNER JOIN DDI.SysTables t ON t.database_id = d.database_id
        AND st.object_id = t.object_id
    INNER JOIN DDI.SysSchemas s ON t.schema_id = s.schema_id
    CROSS APPLY (	SELECT c.name + ',' 
					FROM DDI.SysStatsColumns stc 
						INNER JOIN DDI.SysColumns c ON stc.object_id = c.object_id
							AND stc.column_id = c.column_id
					WHERE stc.object_id = st.object_id 
						AND stc.stats_id = st.stats_id
                    ORDER BY stc.stats_column_id ASC
					FOR XML PATH('')) StatsColumns(StatsColumnList)
GO