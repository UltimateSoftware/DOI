
GO

IF OBJECT_ID('[DOI].[fnGetDataSynchTriggerColumnSelectListForTable]') IS NOT NULL
	DROP FUNCTION [DOI].[fnGetDataSynchTriggerColumnSelectListForTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnGetDataSynchTriggerColumnSelectListForTable](
	@DatabaseName				SYSNAME,
	@SchemaName					SYSNAME, 
	@TableName					SYSNAME, 
	@NumberOfTabs				TINYINT = 1)

RETURNS NVARCHAR(MAX)
AS

/*
	select DOI.[fnGetDataSynchTriggerColumnSelectListForTable]('DBO', 'Pays', 'CREATETABLE', 1, NULL, NULL)
	select DOI.[fnGetDataSynchTriggerColumnSelectListForTable]('ULTIPRO_CALENDAR', 'dbo', 'EmpHJob', 1)
*/

BEGIN
	DECLARE @ColumnList NVARCHAR(MAX) = CHAR(13) + CHAR(10),
			@TabString NVARCHAR(20) = REPLICATE(CHAR(9), @NumberOfTabs)     

	SELECT @ColumnList += @TabString + 
		CASE 
			WHEN @ColumnList = CHAR(13) + CHAR(10) THEN '  ' 
			ELSE ', ' 
		END +  
		CASE
			WHEN OBC.ColumnName IS NULL
			THEN 'T.'
			ELSE 'PT.'
		END + '[' + c.name + ']' + SPACE(1) + CHAR(13) + CHAR(10)
	FROM DOI.SysTables t
        INNER JOIN DOI.SysDatabases d ON T.database_id = d.database_id
		INNER JOIN DOI.SysColumns c ON c.database_id = t.database_id
            AND c.object_id = t.object_id
		INNER JOIN DOI.SysSchemas s ON s.database_id = t.database_id
            AND s.schema_id = t.schema_id
		INNER JOIN DOI.SysTypes ty ON c.user_type_id = ty.user_type_id
		OUTER APPLY (SELECT * FROM DOI.fnOldBlobColumns(d.name, s.name, t.name) WHERE ColumnName = c.name) OBC
	WHERE d.name = @DatabaseName
		AND s.name = @SchemaName
		AND t.name = @TableName
		AND ty.name <> 'TIMESTAMP'
	ORDER BY c.column_id
	RETURN @ColumnList
END

GO
