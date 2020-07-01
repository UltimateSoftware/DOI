IF OBJECT_ID('[DOI].[fnGetPKColumnListForTable]') IS NOT NULL
	DROP FUNCTION [DOI].[fnGetPKColumnListForTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnGetPKColumnListForTable](
    @DatabaseName               SYSNAME,
	@SchemaName					SYSNAME, 
	@TableName					SYSNAME)

RETURNS NVARCHAR(MAX)
AS

/*
	select DOI.[fnGetPKColumnListForTable]('PaymentReporting', 'dbo', 'Pays')
*/

BEGIN
	DECLARE @ColumnList NVARCHAR(MAX) = ''
    
    SELECT @ColumnList += CASE WHEN @ColumnList = '' THEN '' ELSE ',' END + c.name
    --select *
    FROM DOI.SysIndexes i
        INNER JOIN DOI.SysDatabases d ON d.database_id = i.database_id
        INNER JOIN DOI.SysIndexColumns ic ON ic.database_id = i.database_id
            AND ic.object_id = i.object_id
            AND ic.index_id = i.index_id
        INNER JOIN DOI.SysColumns c ON c.database_id = ic.database_id
            AND c.column_id = ic.column_id
            AND c.object_id = ic.object_id
        left JOIN DOI.SysTables t ON t.database_id = c.database_id
            AND t.object_id = c.object_id
        INNER JOIN DOI.SysSchemas s ON s.database_id = t.database_id
            AND s.schema_id = t.schema_id
    WHERE i.is_primary_key = 1
        AND d.name = @DatabaseName
        AND s.name = @SchemaName
        AND t.name = @TableName
    ORDER BY ic.key_ordinal asc

    RETURN @ColumnList
END

GO
