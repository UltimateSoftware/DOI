USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[fnEstimateIndexSize_KeyVarColSize]') IS NOT NULL
	DROP FUNCTION [DOI].[fnEstimateIndexSize_KeyVarColSize];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnEstimateIndexSize_KeyVarColSize]()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   

/*
    SELECT * FROM DOI.fnEstimateIndexSize_KeyVarColSize()   
*/

RETURN  (
            SELECT  IRS.DatabaseName,
                    IRS.SchemaName,
                    IRS.TableName,
                    IRS.IndexName,
                    COUNT(*) AS NumVarCols,
                    SUM(c.max_length) AS VarColSize
            FROM DOI.IndexesRowStore IRS
                INNER JOIN DOI.IndexColumns IRSC ON IRS.DatabaseName = IRSC.DatabaseName
                    AND IRS.SchemaName = IRSC.SchemaName
                    AND IRS.TableName = IRSC.TableName
                    AND IRS.IndexName = IRSC.IndexName
                INNER JOIN DOI.SysSchemas s ON IRS.SchemaName = s.name
                INNER JOIN DOI.SysTables t ON IRS.TableName = t.name
                    AND t.schema_id = s.schema_id
                INNER JOIN DOI.SysColumns c ON c.object_id = t.OBJECT_ID
                    AND IRSC.ColumnName = c.name
                INNER JOIN DOI.SysTypes ty ON ty.user_type_id = c.user_type_id
            WHERE c.object_id = t.object_id
                AND ty.name IN ('VARCHAR', 'NVARCHAR', 'TEXT', 'NTEXT', 'VARBINARY', 'FLOAT', 'DECIMAL', 'NUMERIC')
                AND IRSC.IsKeyColumn = 1
            GROUP BY    IRS.DatabaseName,
                        IRS.SchemaName,
                        IRS.TableName,
                        IRS.IndexName
        )
GO
