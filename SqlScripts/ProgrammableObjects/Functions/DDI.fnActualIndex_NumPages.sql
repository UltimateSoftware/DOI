USE DDI
GO

CREATE OR ALTER FUNCTION DDI.fnActualIndex_NumPages()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   

/*
    SELECT * FROM DDI.fnActualIndex_NumPages()   
*/

RETURN  (
            SELECT  container_id, 
                    SUM(total_pages) AS NumPages
			FROM DDI.SysAllocationUnits a 
                INNER JOIN DDI.SysPartitions p ON p.hobt_id = a.container_id
			GROUP BY a.container_id
        )
GO							
