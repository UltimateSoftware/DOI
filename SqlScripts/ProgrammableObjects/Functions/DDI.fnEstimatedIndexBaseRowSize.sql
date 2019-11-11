/*
CREATE FUNCTION [dbo].[fnDDI_EstimatedIndexBaseRowSize](
    @SchemaName SYSNAME, 
    @TableName SYSNAME, 
    @IndexName SYSNAME)   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   
RETURN (
  
    SELECT  IRS2.SchemaName,
            IRS2.TableName,
            IRS2.IndexName,
            MAX(ISNULL(kfc.NumFixedCols, 0)) AS NumFixedSizeKeyCols,
            MAX(ISNULL(kvc.NumVarCols, 0)) AS NumVarSizeKeyCols,   
            MAX(ISNULL(kfc.FixedColSize, 0)) AS FixedKeyColSize,
            MAX(ISNULL(kvc.MaxVarColSize, 0)) AS MaxVarKeyColSize,    
            COUNT(*) AS NumKeyCols,
            SUM(CASE
                    WHEN ty.name IN ('varchar', 'nvarchar')
                    THEN 2 + c.max_length
                    WHEN ty.name IN ('text', 'ntext')
                    THEN 4 + c.max_length
                    WHEN ty.name IN ('decimal', 'numeric')
                    THEN    CASE 
                                WHEN c.precision BETWEEN 1 AND 9
                                THEN 5
                                WHEN c.precision BETWEEN 10 AND 19
                                THEN 9
                                WHEN c.precision BETWEEN 20 AND 28
                                THEN 13
                                WHEN c.precision BETWEEN 29 AND 38
                                THEN 17
                            END
                    WHEN ty.name = 'float'
                    THEN    CASE
                                WHEN c.precision < 25
                                THEN 4
                                WHEN c.precision BETWEEN 25 AND 53
                                THEN 8
                            END
                    WHEN ty.name = 'time'
                    THEN    CASE
                                WHEN c.scale BETWEEN 0 AND 2
                                THEN 3
                                WHEN c.scale BETWEEN 3 AND 4
                                THEN 4
                                WHEN c.scale BETWEEN 5 AND 7
                                THEN 5
                            END 
                    WHEN ty.name = 'datetime2'
                    THEN    CASE
                                WHEN c.scale BETWEEN 1 AND 2
                                THEN 6
                                WHEN c.scale BETWEEN 3 AND 4
                                THEN 7
                                WHEN c.scale BETWEEN 5 AND 7
                                THEN 8
                            END
                    WHEN ty.name = 'datetimeoffset'
                    THEN    CASE
                                WHEN c.scale BETWEEN 1 AND 2
                                THEN 8
                                WHEN c.scale BETWEEN 3 AND 4
                                THEN 9
                                WHEN c.scale BETWEEN 5 AND 7
                                THEN 10
                            END
                    WHEN ty.name = 'bit'
                    THEN .125 
                    ELSE c.max_length                                            
                END)
                + SUM(  CASE 
                            WHEN ty.name IN ('decimal', 'numeric')
                            THEN c.precision
                            ELSE 0
                        END)
                + SUM(  CASE 
                            WHEN ty.name IN ('decimal', 'numeric')
                            THEN c.scale
                            ELSE 0
                        END) AS ColumnSize
    FROM Utility.IndexesRowStore IRS2
        CROSS APPLY STRING_SPLIT(IRS2.KeyColumnList,',') KCL
        INNER JOIN DDI.SysSchemas s ON IRS2.SchemaName = s.name
        INNER JOIN DDI.SysTables t ON IRS2.TableName = t.name   
            AND t.schema_id = s.schema_id
        INNER JOIN DDI.SysColumns c ON c.object_id = t.object_id
            AND c.name = REPLACE(REPLACE(KCL.VALUE, ' ASC', ''), ' DESC', '')
        INNER JOIN DDI.SysTypes ty ON c.user_type_id = ty.user_type_id
        OUTER APPLY (   SELECT  c.object_id,
                                IRS3.IndexName,
                                COUNT(*) AS NumFixedCols,
                                SUM(c.max_length) AS FixedColSize
                        FROM Utility.IndexesRowStore IRS3
                            INNER JOIN DDI.SysSchemas s ON IRS3.SchemaName = s.name
                            INNER JOIN DDI.SysTables t ON IRS3.TableName = t.name
                                AND t.schema_id = s.schema_id
                            INNER JOIN DDI.SysColumns c ON c.object_id = t.object_id
                            CROSS APPLY (   SELECT REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') AS ColumnName
                                            FROM STRING_SPLIT(IRS3.KeyColumnList, ',')
                                            WHERE REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') = C.NAME) CL
                            INNER JOIN DDI.SysTypes ty ON ty.user_type_id = c.user_type_id
                        WHERE c.object_id = t.object_id
                            AND ty.name NOT IN ('VARCHAR', 'NVARCHAR', 'TEXT', 'NTEXT', 'VARBINARY', 'FLOAT', 'DECIMAL', 'NUMERIC')
                            AND IRS3.SchemaName = IRS2.SchemaName
                            AND IRS3.TableName = IRS2.TableName
                            AND IRS3.IndexName = IRS2.IndexName
                        GROUP BY c.object_id, IRS3.IndexName) kfc
        OUTER APPLY (   SELECT  c.object_id,
                                IRS3.IndexName,
                                COUNT(*) AS NumVarCols,
                                SUM(c.max_length) AS MaxVarColSize
                        FROM Utility.IndexesRowStore IRS3
                            INNER JOIN DDI.SysSchemas s ON IRS3.SchemaName = s.name
                            INNER JOIN DDI.SysTables t ON IRS3.TableName = t.name
                                AND t.schema_id = s.schema_id
                            INNER JOIN DDI.SysColumns c ON c.object_id = t.object_id
                            CROSS APPLY (   SELECT REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') AS ColumnName
                                            FROM STRING_SPLIT(IRS3.KeyColumnList, ',')
                                            WHERE REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') = C.NAME) CL
                            INNER JOIN DDI.SysTypes ty ON ty.user_type_id = c.user_type_id
                        WHERE c.object_id = t.object_id
                            AND ty.name IN ('VARCHAR', 'NVARCHAR', 'TEXT', 'NTEXT', 'VARBINARY', 'FLOAT', 'DECIMAL', 'NUMERIC')
                            AND IRS3.SchemaName = IRS2.SchemaName
                            AND IRS3.TableName = IRS2.TableName
                            AND IRS3.IndexName = IRS2.IndexName
                        GROUP BY c.object_id, IRS3.IndexName) kvc
    WHERE IRS.SchemaName = IRS2.SchemaName
        AND IRS.TableName = IRS2.TableName
        AND IRS.IndexName = IRS2.IndexName
    GROUP BY IRS2.SchemaName, IRS2.TableName, IRS2.IndexName  
)  
GO*/
