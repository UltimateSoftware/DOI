IF OBJECT_ID('[DOI].[fnGetColumnListForTable]') IS NOT NULL
	DROP FUNCTION [DOI].[fnGetColumnListForTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnGetColumnListForTable](
	@SchemaName					SYSNAME, 
	@TableName					SYSNAME, 
	@ListType					VARCHAR(50),
	@NumberOfTabs				TINYINT = 1,
	@SourceTableAlias			VARCHAR(50) = NULL,
	@DestinationTableAlias		VARCHAR(50) = NULL)

RETURNS NVARCHAR(MAX)
AS

/*
	select DOI.[fnGetColumnListForTable]('DBO', 'Pays', 'CREATETABLE', 1, NULL, NULL)
	select DOI.[fnGetColumnListForTable]('DBO', 'Pays', 'insert', 1, 'S', 'D')
*/

BEGIN
	DECLARE @ColumnList NVARCHAR(MAX) = CHAR(13) + CHAR(10),
			@ShowNullability BIT = CASE WHEN @ListType IN ('CREATETABLE') THEN 1 ELSE 0 END,
			@ShowDataTypes BIT = CASE WHEN @ListType IN ('CREATETABLE', 'DECLARE') THEN 1 ELSE 0 END,
			@ShowParameterMarker BIT = CASE WHEN @ListType IN ('DECLARE', 'SELECTPARAMASSIGN') THEN 1 ELSE 0 END,
			@TabString NVARCHAR(20) = REPLICATE(CHAR(9), @NumberOfTabs)

	
	DECLARE
			@NameDelimiterBeginMarker CHAR(1) = CASE WHEN @ShowParameterMarker = 1 THEN '' ELSE '[' END,
			@NameDelimiterEndMarker CHAR(1) = CASE WHEN @ShowParameterMarker = 1 THEN '' ELSE ']' END       

	SELECT @ColumnList += @TabString + 
		CASE 
			WHEN @ColumnList = CHAR(13) + CHAR(10) THEN '  ' 
			ELSE ', ' 
		END + 
		CASE 
			WHEN @SourceTableAlias IS NULL 
			THEN '' 
			ELSE @SourceTableAlias + '.' 
		END +
		@NameDelimiterBeginMarker + 
		CASE WHEN @ShowParameterMarker = 1 
			THEN '@' 
			ELSE '' 
		END + c.name + @NameDelimiterEndMarker + 
		CASE	
			WHEN @ListType = 'SELECTPARAMASSIGN'
			THEN ' = ' + '[' + c.name + ']'
			WHEN @ListType = 'UPDATE'
			THEN ' = ' + @DestinationTableAlias + '.[' + c.name + ']'
			ELSE ''
		END + SPACE(1) +
		CASE 
			WHEN @ShowDataTypes = 1
			THEN UPPER(ty.name) + 
				CASE 
					WHEN ty.NAME LIKE '%CHAR%' 
					THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(CASE WHEN c.user_type_id IN (231, 239) THEN c.max_length/2 ELSE c.max_length END AS NVARCHAR(10)) END  + ')' 
					WHEN ty.NAME IN ('DECIMAL', 'NUMERIC')
					THEN '(' + CAST(c.precision AS NVARCHAR(10)) + ', ' + CAST(c.scale AS NVARCHAR(10)) + ')' 
					ELSE '' 
				END + 
				CASE 
					WHEN @ShowNullability = 1 
					THEN CASE c.is_nullable WHEN 0 THEN ' NOT' ELSE SPACE(0) END + ' NULL' 
					ELSE '' 
				END
			ELSE ''
		END + CHAR(13) + CHAR(10)
	FROM DOI.SysTables t
        INNER JOIN DOI.SysDatabases d ON T.database_id = d.database_id
		INNER JOIN DOI.SysColumns c ON c.database_id = t.database_id
            AND c.object_id = t.object_id
		INNER JOIN DOI.SysSchemas s ON s.database_id = t.database_id
            AND s.schema_id = t.schema_id
		INNER JOIN DOI.SysTypes ty ON c.user_type_id = ty.user_type_id
	WHERE s.name = @SchemaName
		AND t.name = @TableName
        AND C.is_computed = CASE WHEN @ListType = 'INSERT' THEN 0 ELSE C.is_computed END 
	ORDER BY c.column_id
	RETURN @ColumnList
END

GO
