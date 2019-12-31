IF OBJECT_ID('[DDI].[spLoadDataFromBackupTableWithDateName]') IS NOT NULL
	DROP PROCEDURE [DDI].[spLoadDataFromBackupTableWithDateName];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spLoadDataFromBackupTableWithDateName]
    @DatabaseName SYSNAME,
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@Debug BIT = 0

AS

/*
	EXEC DDI.spLoadDataFromBackupTableWithDatename 
		@SchemaName = 'DDI',
		@TableName = 'ReportTraceFlags',
		@Debug = 1
*/

DECLARE @SQL NVARCHAR(MAX) = '',
        @ColumnList NVARCHAR(MAX) = '',
        @JoinClause NVARCHAR(MAX) = ''

DECLARE @now VARCHAR(30) = CONVERT(VARCHAR(30), SYSDATETIME(),112)

DECLARE @BackupTableName sysname = @TableName + '_' + @now

SET @ColumnList += (SELECT DDI.fnGetColumnListForTable(@SchemaName, @TableName, 'INSERT', 1, 'B', 'O'))
SET @JoinClause += (SELECT DDI.fnGetJoinClauseForTable(@DatabaseName, @SchemaName, @TableName, 7, 'B', 'O'))

SELECT @SQL += '
IF OBJECT_ID(''' + @SchemaName + '.' + @TableName + ''') IS NOT NULL
    AND OBJECT_ID(''' + @SchemaName + '.' + @BackupTableName + ''') IS NOT NULL
BEGIN
    INSERT INTO ' + @SchemaName + '.' + @TableName + '(' + @ColumnList + ')
    SELECT ' + @ColumnList + '
    FROM ' + @SchemaName + '.' + @BackupTableName + ' B
    WHERE NOT EXISTS(   SELECT ''True'' 
                        FROM ' + @SchemaName + '.' + @TableName + ' O
                        WHERE ' + @JoinClause + ')
END'

IF @Debug = 1
BEGIN
	EXEC DDI.spPrintOutLongSQL 
		@SQLInput = @SQL ,
	    @VariableName = N'@SQL'
END
ELSE
BEGIN
	EXEC dbo.sp_ExecuteSQL 
		@SQL = @SQL
END
GO
