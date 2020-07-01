IF OBJECT_ID('[DOI].[fnActualIndex_Frag]') IS NOT NULL
	DROP FUNCTION [DOI].[fnActualIndex_Frag];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnActualIndex_Frag]()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   

/*
    SELECT * FROM DOI.fnActualIndex_Frag()   
*/

RETURN  (
            SELECT  d.name AS DatabaseName,
                    s.name AS SchemaName,
                    t.name AS TableName, 
                    i.name AS IndexName, 
                    MAX(avg_fragmentation_in_percent) AS Fragmentation
			FROM DOI.SysIndexPhysicalStats p
                INNER JOIN DOI.SysDatabases d on p.database_id = d.database_id
                INNER JOIN DOI.SysSchemas s ON s.database_id = d.database_id
                INNER JOIN DOI.SysTables t ON t.database_id = d.database_id
                    AND t.schema_id = s.schema_id
                    AND t.object_id = p.object_id
                INNER JOIN DOI.SysIndexes i ON d.database_id = i.database_id
                    AND p.object_id = i.object_id
				    AND p.index_id = i.index_id	
			GROUP BY d.name, s.name, t.name, i.name
        )
GO
