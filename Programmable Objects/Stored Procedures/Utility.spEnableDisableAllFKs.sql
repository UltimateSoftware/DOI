USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[Utility].[spEnableDisableAllFKs]') IS NOT NULL
	DROP PROCEDURE [Utility].[spEnableDisableAllFKs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [Utility].[spEnableDisableAllFKs]
    @DatabaseName SYSNAME,
	@Action VARCHAR(10) ,
	@InternalDebug BIT = 0,
	@Debug BIT = 0

AS

/*
	exec Utility.spEnableDisableAllFKs 
        @DatabaseName = 'PaymentReporting',
        @Action = 'Disable', 
		@InternalDebug = 1,
        @Debug = 1
*/
BEGIN TRY 
	DECLARE @InternalSQL NVARCHAR(MAX) = '',
			@SQL NVARCHAR(MAX) = 'USE ' + @DatabaseName + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10),
			@SQL_Out NVARCHAR(MAX),
			@ParamList NVARCHAR(50) = '@SQL_Out NVARCHAR(MAX) OUTPUT'

    SELECT @InternalSQL += '
	                SELECT @SQL_Out += ''ALTER TABLE '' + ps.name + ''.['' + pt.name + ''] ' + CASE WHEN @Action = 'Enable' THEN SPACE(0) ELSE 'NO' END + 'CHECK CONSTRAINT '' + FK.name + CHAR(13) + CHAR(10)
                    --SELECT fk.*
	                FROM ' + @DatabaseName + '.sys.foreign_keys fk
		                INNER JOIN ' + @DatabaseName + '.sys.tables pt ON pt.object_id = fk.parent_object_id
		                INNER JOIN ' + @DatabaseName + '.sys.schemas ps ON pt.schema_id = ps.schema_id
	                WHERE is_disabled = ' + CASE WHEN @Action = 'Disable' THEN '0' ELSE '1' END

	IF @InternalDebug = 1
	BEGIN
		EXEC DOI.spPrintOutLongSQL
			@SQLInput = @InternalSQL,
			@VariableName = '@InternalSQL'
	END

	EXEC sp_ExecuteSQL
		@stmt = @InternalSQL,
		@Params = @ParamList,
		@SQL_Out = @SQL OUTPUT

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
