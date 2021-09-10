
GO

IF OBJECT_ID('[DOI].[fnGetColumnListForTable]') IS NOT NULL
	DROP FUNCTION [DOI].[fnGetColumnListForTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnGetColumnListForTable](
	@DatabaseName				SYSNAME,
	@SchemaName					SYSNAME, 
	@TableName					SYSNAME, 
	@ListType					NVARCHAR(50),
	@NumberOfTabs				TINYINT = 1,
	@SourceTableAlias			NVARCHAR(50) = NULL,
	@DestinationTableAlias		NVARCHAR(50) = NULL,
	@ShowIdentityProperty		BIT = 1)

RETURNS NVARCHAR(MAX)
AS

/*
	select DOI.[fnGetColumnListForTable]('DBO', 'Pays', 'CREATETABLE', 1, NULL, NULL)
	select DOI.[fnGetColumnListForTable]('DBO', 'Pays', 'insert', 1, 'S', 'D')
*/

BEGIN
	DECLARE @ColumnList NVARCHAR(MAX) = NCHAR(13) + NCHAR(10),
			@ShowNullability BIT = CASE WHEN @ListType IN (N'CREATETABLE') THEN 1 ELSE 0 END,
			@ShowDataTypes BIT = CASE WHEN @ListType IN (N'CREATETABLE', N'DECLARE') THEN 1 ELSE 0 END,
			@ShowParameterMarker NCHAR(1) = CASE WHEN @ListType IN (N'DECLARE', N'SELECTPARAMASSIGN') THEN N'1' ELSE N'0' END,
			@TabString NVARCHAR(20) = REPLICATE(CHAR(9), @NumberOfTabs),
			@ShowComputedColumns BIT = CASE WHEN @ListType = N'INSERT' THEN 1 ELSE 0 END

	
	DECLARE
			@NameDelimiterBeginMarker NCHAR(1) = CASE WHEN @ShowParameterMarker = 1 THEN N'' ELSE N'[' END,
			@NameDelimiterEndMarker NCHAR(1) = CASE WHEN @ShowParameterMarker = 1 THEN N'' ELSE N']' END       

	SELECT @ColumnList += @TabString + 
		CASE 
			WHEN @ColumnList = NCHAR(13) + NCHAR(10) THEN N'  ' 
			ELSE N', ' 
		END + 
		CASE 
			WHEN @SourceTableAlias IS NULL 
			THEN N'' 
			ELSE @SourceTableAlias + N'.' 
		END +
		@NameDelimiterBeginMarker + 
		CASE WHEN @ShowParameterMarker = N'1' 
			THEN N'@' 
			ELSE N'' 
		END + c.name + @NameDelimiterEndMarker + 
		CASE	
			WHEN @ListType = N'SELECTPARAMASSIGN'
			THEN N' = ' + N'[' + c.name + N']'
			WHEN @ListType = N'UPDATE'
			THEN N' = ' + @DestinationTableAlias + N'.[' + c.name + N']'
			ELSE N''
		END + N' ' +
		CASE 
			WHEN @ShowDataTypes = 1
			THEN UPPER(ty.name) + 
				CASE 
					WHEN ty.NAME LIKE '%CHAR%' 
					THEN N'(' + CASE WHEN c.max_length = -1 THEN N'MAX' ELSE CAST(CASE WHEN c.user_type_id IN (231, 239) THEN c.max_length/2 ELSE c.max_length END AS NVARCHAR(10)) END  + N')' 
					WHEN ty.NAME IN ('DECIMAL', 'NUMERIC')
					THEN N'(' + CAST(c.precision AS NVARCHAR(10)) + ', ' + CAST(c.scale AS NVARCHAR(10)) + N')' 
					WHEN ty.name LIKE '%INT'
					THEN CASE WHEN c.is_identity = 1 AND @ShowIdentityProperty = 1 THEN N' IDENTITY(' + CAST(ic.seed_value AS NVARCHAR(10)) + N', ' + CAST(ic.increment_value AS NVARCHAR(10)) + N')' ELSE N'' END
					ELSE N'' 
				END + 

				CASE 
					WHEN @ShowNullability = 1 
					THEN CASE c.is_nullable WHEN 0 THEN N' NOT' ELSE SPACE(0) END + N' NULL' 
					ELSE N'' 
				END
			ELSE N''
		END + NCHAR(13) + NCHAR(10)
	FROM DOI.SysTables t
   		INNER JOIN DOI.SysDatabases d ON T.database_id = d.database_id
		INNER JOIN DOI.SysColumns c ON c.database_id = t.database_id
	            AND c.object_id = t.object_id
		INNER JOIN DOI.SysSchemas s ON s.database_id = t.database_id
        	    AND s.schema_id = t.schema_id
		INNER JOIN DOI.SysTypes ty ON ty.database_id = t.database_id
	            AND c.user_type_id = ty.user_type_id
		LEFT JOIN DOI.SysIdentityColumns ic ON c.database_id = ic.database_id
			AND c.object_id = ic.object_id
			AND c.column_id = ic.column_id
	WHERE d.name = @DatabaseName
		AND s.name = @SchemaName
		AND t.name = @TableName
        AND C.is_computed = @ShowComputedColumns
	ORDER BY c.column_id
	RETURN @ColumnList
END

GO