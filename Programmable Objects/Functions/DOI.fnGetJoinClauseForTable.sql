
GO

IF OBJECT_ID('[DOI].[fnGetJoinClauseForTable]') IS NOT NULL
	DROP FUNCTION [DOI].[fnGetJoinClauseForTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnGetJoinClauseForTable](
    @DatabaseName               SYSNAME,
	@SchemaName					SYSNAME, 
	@TableName					SYSNAME, 
	@NumberOfTabs				TINYINT = 1,
	@SourceTableAlias			NVARCHAR(50) = '',
	@DestinationTableAlias		NVARCHAR(50) = '')

RETURNS NVARCHAR(MAX)
AS

/*
	select [DOI].[fnGetJoinClauseForTable]('DBO', 'Pays', 1, 'S', 'D')
    select [DOI].[fnGetJoinClauseForTable]('DBO', 'Pays', 1)
*/

BEGIN
	DECLARE @ColumnList NVARCHAR(MAX) = N'',
            @TabString NVARCHAR(50) = REPLICATE(NCHAR(9), @NumberOfTabs)
    
    SELECT @ColumnList += CASE WHEN @ColumnList = N'' THEN N'' ELSE @TabString + N'AND ' END + @SourceTableAlias + N'.' + c.name + N' = ' + @DestinationTableAlias + N'.' + c.name + NCHAR(13) + NCHAR(10)
    FROM DOI.SysIndexes i
        INNER JOIN DOI.SysDatabases d ON d.database_id = i.database_id
        INNER JOIN DOI.SysIndexColumns ic ON ic.database_id = i.database_id
            AND ic.index_id = i.index_id
            AND ic.object_id = i.object_id
        INNER JOIN DOI.SysColumns c ON c.database_id = ic.database_id
            AND c.column_id = ic.column_id
            AND c.object_id = ic.OBJECT_ID
        INNER JOIN DOI.SysTables t ON t.database_id = C.database_id
            AND t.OBJECT_ID = C.OBJECT_ID
        INNER JOIN DOI.SysSchemas s ON s.database_id = t.database_id
            AND s.SCHEMA_ID = t.SCHEMA_ID
    WHERE i.is_primary_key = 1
        AND d.NAME = @DatabaseName
        AND s.name = @SchemaName
        AND t.name = @TableName
    ORDER BY ic.key_ordinal asc

    RETURN @ColumnList
END

GO
