IF OBJECT_ID('[DDI].[fnActualIndex_NumPages]') IS NOT NULL
	DROP FUNCTION [DDI].[fnActualIndex_NumPages];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DDI].[fnActualIndex_NumPages]()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   

/*
    SELECT * FROM DDI.fnActualIndex_NumPages()   
*/

RETURN  (
            SELECT  p.database_id,
                    container_id, 
                    SUM(total_pages) AS NumPages
			FROM DDI.SysAllocationUnits a 
                INNER JOIN DDI.SysPartitions p ON p.hobt_id = a.container_id
			GROUP BY p.database_id, a.container_id
        )
GO
