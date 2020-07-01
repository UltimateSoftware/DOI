IF OBJECT_ID('[DOI].[spBackupTableWithDateName]') IS NOT NULL
	DROP PROCEDURE [DOI].[spBackupTableWithDateName];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spBackupTableWithDateName]
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@Debug BIT = 0

AS

/*
	EXEC Utility.spBackupTableWithDateName 
		@SchemaName = 'Utility',
		@TableName = 'IndexesNotInMetadata',
		@Debug = 1
*/

DECLARE @SQL NVARCHAR(MAX) = ''

DECLARE @now VARCHAR(30) = CONVERT(VARCHAR(30), SYSDATETIME(),112)

SELECT @SQL += '
IF OBJECT_ID(''' + @SchemaName + '.' + @TableName + ''') IS NOT NULL
BEGIN
	--IF TABLE HAS DATA, BACK IT UP BEFORE DROPPING.
	IF EXISTS (SELECT ''True'' FROM ' + @SchemaName + '.' + @TableName + ')
	BEGIN
		IF OBJECT_ID(''' + @SchemaName + '.' + @TableName + '_' + @now + ''') IS NOT NULL
		BEGIN	
			DROP TABLE ' + @SchemaName + '.' + @TableName + '_' + @now + '
		END

		SELECT * INTO ' + @SchemaName + '.' + @TableName + '_' + @now + ' FROM ' + @SchemaName + '.' + @TableName + '
	END
END'

IF @Debug = 1
BEGIN
	EXEC DOI.spPrintOutLongSQL 
		@SQLInput = @SQL ,
	    @VariableName = N'@SQL'
END
ELSE
BEGIN
	EXEC dbo.sp_ExecuteSQL 
		@SQL = @SQL
END
GO
