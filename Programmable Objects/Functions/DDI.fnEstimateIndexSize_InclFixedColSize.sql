IF OBJECT_ID('[DDI].[fnEstimateIndexSize_InclFixedColSize]') IS NOT NULL
	DROP FUNCTION [DDI].[fnEstimateIndexSize_InclFixedColSize];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DDI].[fnEstimateIndexSize_InclFixedColSize]()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   

/*
    SELECT * FROM DDI.fnEstimateIndexSize_InclFixedColSize()   
*/

RETURN  (
            SELECT  IRS.DatabaseName,
                    IRS.SchemaName,
                    IRS.TableName,
                    IRS.IndexName,
                    COUNT(*) AS NumInclFixedCols,
                    SUM(c.max_length) AS FixedInclColSize
--select count(*)
            FROM DDI.IndexesRowStore IRS
                INNER JOIN DDI.IndexColumns IRSC ON IRS.DatabaseName = IRSC.DatabaseName
                    AND IRS.SchemaName = IRSC.SchemaName
                    AND IRS.TableName = IRSC.TableName
                    AND IRS.IndexName = IRSC.IndexName
                INNER JOIN DDI.SysSchemas s ON IRS.SchemaName = s.name
                INNER JOIN DDI.SysTables t ON IRS.TableName = t.name
                    AND t.schema_id = s.schema_id
                INNER JOIN DDI.SysColumns c ON c.object_id = t.OBJECT_ID
                    AND IRSC.ColumnName = c.name
                INNER JOIN DDI.SysTypes ty ON ty.user_type_id = c.user_type_id
            WHERE c.object_id = t.object_id
                AND ty.name NOT IN ('VARCHAR', 'NVARCHAR', 'TEXT', 'NTEXT', 'VARBINARY', 'FLOAT', 'DECIMAL', 'NUMERIC')
                AND IRSC.IsIncludedColumn = 1
            GROUP BY    IRS.DatabaseName,
                        IRS.SchemaName,
                        IRS.TableName,
                        IRS.IndexName
        )
GO
