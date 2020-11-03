
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysStats_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysStats_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysStats_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysStats_UpdateData]
        @DatabaseName = 'DOIUnitTests'
*/

UPDATE ST
SET ST.column_list = STUFF(StatsColumnList,LEN(StatsColumnList),1,'')
--SELECT *
FROM DOI.SysStats ST
    INNER JOIN DOI.SysDatabases d ON d.database_id = ST.database_id
    CROSS APPLY (	SELECT c.name + ',' 
					FROM DOI.SysStatsColumns stc 
						INNER JOIN DOI.SysColumns c ON stc.database_id = c.database_id
                            AND stc.object_id = c.object_id
							AND stc.column_id = c.column_id
					WHERE stc.database_id = st.database_id
                        AND stc.object_id = st.object_id 
						AND stc.stats_id = st.stats_id
                    ORDER BY stc.stats_column_id ASC
					FOR XML PATH('')) StatsColumns(StatsColumnList)
WHERE d.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

GO