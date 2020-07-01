IF OBJECT_ID('[Utility].[spEnableDisableAllFKs]') IS NOT NULL
	DROP PROCEDURE [Utility].[spEnableDisableAllFKs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [Utility].[spEnableDisableAllFKs]
	@Action VARCHAR(10) ,
	@Debug BIT = 0

AS

/*
	exec Utility.spEnableDisableAllFKs 'disable', 1

*/
BEGIN TRY 
	DECLARE @SQL NVARCHAR(MAX) = ''

	SELECT @SQL += 'ALTER TABLE ' + ps.name + '.[' + pt.name + ']' + CASE WHEN @Action = 'Enable' THEN ' ' ELSE ' NO' END + 'CHECK CONSTRAINT ' + FK.name + CHAR(13) + CHAR(10)
    --SELECT fk.*
	FROM sys.foreign_keys fk
		INNER JOIN sys.tables pt ON pt.object_id = fk.parent_object_id
		INNER JOIN sys.schemas ps ON pt.schema_id = ps.schema_id
	WHERE is_disabled = CASE WHEN @Action = 'Disable' THEN 0 ELSE 1 END

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
