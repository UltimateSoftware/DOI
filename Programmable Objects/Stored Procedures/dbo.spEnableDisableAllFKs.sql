IF OBJECT_ID('[dbo].[spEnableDisableAllFKs]') IS NOT NULL
	DROP PROCEDURE [dbo].[spEnableDisableAllFKs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [dbo].[spEnableDisableAllFKs]
	@Action VARCHAR(10) ,
	@Debug BIT = 0

AS

/*
	exec dbo.spEnableDisableAllFKs 'enable', 1

*/
BEGIN TRY 
	DECLARE @SQL NVARCHAR(MAX) = ''

	select @SQL += 'ALTER TABLE ' + s.name + '.[' + t.name + ']' + CASE WHEN @Action = 'Enable' THEN ' ' ELSE ' NO' END + 'CHECK CONSTRAINT ' + FK.name + CHAR(13) + CHAR(10)
	from sys.foreign_keys fk
		INNER JOIN sys.tables t on fk.parent_object_id = t.object_id
		INNER JOIN sys.schemas s on t.schema_id = s.schema_id
	where s.name <> 'Utility' 
        AND is_disabled = CASE WHEN @Action = 'Disable' THEN 0 ELSE 1 END

	IF @Debug = 1
	BEGIN
		EXEC ddi.spPrintOutLongSQL
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
