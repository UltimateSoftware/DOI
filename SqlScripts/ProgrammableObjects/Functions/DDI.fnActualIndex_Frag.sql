USE DDI
GO

CREATE OR ALTER FUNCTION DDI.fnActualIndex_Frag()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   

/*
    SELECT * FROM DDI.fnActualIndex_Frag()   
*/

RETURN  (
            SELECT  p.object_id, 
                    p.index_id, 
                    MAX(avg_fragmentation_in_percent) AS Fragmentation
			FROM DDI.SysIndexPhysicalStats p
                INNER JOIN DDI.SysIndexes i ON p.object_id = i.object_id
				    AND p.index_id = i.index_id	
			GROUP BY p.object_id, p.index_id
        )
GO
