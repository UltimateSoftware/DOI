IF OBJECT_ID('[DOI].[fnActualIndex_NumPages]') IS NOT NULL
	DROP FUNCTION [DOI].[fnActualIndex_NumPages];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnActualIndex_NumPages]()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   

/*
    SELECT * FROM DOI.fnActualIndex_NumPages()   
*/

RETURN  (
            SELECT  p.database_id,
                    container_id, 
                    SUM(total_pages) AS NumPages
			FROM DOI.SysAllocationUnits a 
                INNER JOIN DOI.SysPartitions p ON p.hobt_id = a.container_id
			GROUP BY p.database_id, a.container_id
        )
GO
