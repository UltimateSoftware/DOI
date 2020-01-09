IF OBJECT_ID('[DDI].[fnFixStatsSampleSize]') IS NOT NULL
	DROP FUNCTION [DDI].[fnFixStatsSampleSize];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     FUNCTION [DDI].[fnFixStatsSampleSize](@DesiredPctSampleSize TINYINT)
RETURNS TABLE
AS RETURN

/*
    select * from DDI.fnFixStatsSampleSize(99)
*/

(
    SELECT  d.name AS DatabaseName,
            s.name AS SchemaName,
            t.name AS TableName,
            st.name AS StatsName, 
            rows, 
            rows_sampled, 
            CAST((((sp.rows_sampled * 1.00)/rows) * 100) AS DECIMAL(5,2)) AS SamplePct,
            @DesiredPctSampleSize AS DesiredSamplePct,
            last_updated, 
            steps, 
            filter_definition, 
            unfiltered_rows, 
            modification_counter,
            'UPDATE STATISTICS ' + S.NAME + '.' + T.NAME + '(' + st.name + ') WITH SAMPLE ' + CAST(@DesiredPctSampleSize AS VARCHAR(3)) + ' PERCENT;' AS UpdateSampleSizeSQL
--SELECT COUNT(*)
    FROM DDI.SysStats AS st
        INNER JOIN DDI.SysDatabases d ON d.database_id = st.database_id
	    INNER JOIN DDI.SysDmDbStatsProperties sp ON sp.database_id = d.database_id
            AND sp.object_id = st.object_id
            AND sp.stats_id = st.stats_id  
        INNER JOIN  DDI.SysTables t ON t.database_id = d.database_id
            AND st.object_id = t.object_id
        INNER JOIN  DDI.SysSchemas s ON s.database_id = d.database_id
            AND s.schema_id = t.schema_id
    WHERE (((sp.rows_sampled * 1.00)/rows) * 100) < @DesiredPctSampleSize
)
GO
