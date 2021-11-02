

IF OBJECT_ID('[DOI].[fnOldBlobColumns]') IS NOT NULL
	DROP FUNCTION [DOI].[fnOldBlobColumns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION DOI.fnOldBlobColumns 
(	
	@DatabaseName SYSNAME, 
	@SchemaName SYSNAME,
    @TableName SYSNAME
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT  D.name AS DatabaseName,
            S.name AS SchemaName,
            T.name AS TableName,
            C.name AS ColumnName,
            TY.name AS DataType
    FROM DOI.SysColumns C
        INNER JOIN DOI.SysDatabases D ON D.database_id = C.database_id
        INNER JOIN DOI.DOI.SysSchemas S ON S.database_id = C.database_id
        INNER JOIN DOI.SysTables T ON T.database_id = c.database_id
            AND T.schema_id = S.schema_id
            AND T.object_id = c.object_id
        INNER JOIN DOI.SysTypes TY ON TY.database_id = c.database_id
            AND TY.user_type_id = c.user_type_id
    WHERE TY.name IN ('TEXT', 'NTEXT', 'IMAGE')
        AND D.name = @DatabaseName
        AND S.name = @SchemaName
        AND T.name = @TableName
)
GO