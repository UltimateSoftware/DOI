USE [$(DatabaseName2)]
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
	@SourceTableAlias			VARCHAR(50) = '',
	@DestinationTableAlias		VARCHAR(50) = '')

RETURNS NVARCHAR(MAX)
AS

/*
	select [DOI].[fnGetJoinClauseForTable]('DBO', 'Pays', 1, 'S', 'D')
    select [DOI].[fnGetJoinClauseForTable]('DBO', 'Pays', 1)
*/

BEGIN
	DECLARE @ColumnList NVARCHAR(MAX) = '',
            @TabString NVARCHAR(50) = REPLICATE(CHAR(9), @NumberOfTabs)
    
    SELECT @ColumnList += CASE WHEN @ColumnList = '' THEN '' ELSE @TabString + 'AND ' END + @SourceTableAlias + '.' + c.name + ' = ' + @DestinationTableAlias + '.' + c.name + CHAR(13) + CHAR(10)
    FROM DOI.SysIndexes i
        INNER JOIN DOI.SysDatabases d ON d.database_id = i.database_id
        INNER JOIN DOI.SysIndexColumns ic ON ic.index_id = i.index_id
            AND ic.object_id = i.object_id
        INNER JOIN DOI.SysColumns c ON c.column_id = ic.column_id
            AND c.object_id = ic.object_id
        INNER JOIN DOI.SysTables t ON t.object_id = c.object_id
        INNER JOIN DOI.SysSchemas s ON s.schema_id = t.schema_id
    WHERE i.is_primary_key = 1
        AND s.name = @SchemaName
        AND t.name = @TableName
    ORDER BY ic.key_ordinal asc

    RETURN @ColumnList
END

GO
