IF OBJECT_ID('[DOI].[spEnableDisableAllFKs]') IS NOT NULL
	DROP PROCEDURE [DOI].[spEnableDisableAllFKs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spEnableDisableAllFKs]
    @DatabaseName SYSNAME,
	@Action VARCHAR(10) ,
	@Debug BIT = 0

AS

/*
	exec dbo.spEnableDisableAllFKs 
    'enable', 1

*/
BEGIN TRY 
	DECLARE @SQL NVARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10)

	SELECT @SQL += 'ALTER TABLE ' + ps.name + '.[' + pt.name + ']' + CASE WHEN @Action = 'Enable' THEN ' ' ELSE ' NO' END + 'CHECK CONSTRAINT ' + FK.name + CHAR(13) + CHAR(10)
    --SELECT fk.*
	FROM DOI.SysForeignKeys fk
        INNER JOIN DOI.SysDatabases D ON D.database_id = fk.database_id
		INNER JOIN DOI.SysTables pt ON pt.database_id = fk.database_id
            AND pt.object_id = fk.parent_object_id
		INNER JOIN DOI.SysSchemas ps ON ps.database_id = pt.database_id
            AND pt.schema_id = ps.schema_id
	WHERE is_disabled = CASE WHEN @Action = 'Disable' THEN 0 ELSE 1 END
        AND D.name = @DatabaseName

	IF @Debug = 1
	BEGIN
		EXEC DOI.spPrintOutLongSQL
			@SQLInput = @SQL,
			@VariableName = '@SQL'
	END
	ELSE
	BEGIN
		EXEC(@SQL)
	END
END TRY
BEGIN CATCH
	THROW;
END CATCH
GO
