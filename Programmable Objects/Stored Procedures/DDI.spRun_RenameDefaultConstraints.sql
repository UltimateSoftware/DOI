IF OBJECT_ID('[DDI].[spRun_RenameDefaultConstraints]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRun_RenameDefaultConstraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRun_RenameDefaultConstraints]
    @DatabaseName SYSNAME = null,
	@Debug BIT = 0

AS

/*
	EXEC DDI.spRun_RenameDefaultConstraints @Debug = 1
*/

DECLARE @RenameDefaultConstraints VARCHAR(MAX) = ''

SELECT @RenameDefaultConstraints += 'EXEC ' + @DatabaseName + '.sys.sp_rename @objname = ''' + s.name + '.' + d.name + ''', @newname = ''Def_' + t.name + '_' + c.name + ''', @objtype =''OBJECT''' + CHAR(13) + CHAR(10)
--SELECT *
FROM DDI.SysDefaultConstraints d
    INNER JOIN DDI.SysDatabases db ON db.database_id = d.database_id
	INNER JOIN DDI.SysSchemas s ON s.schema_id = d.schema_id
	INNER JOIN DDI.SysTables t ON d.parent_object_id = t.object_id
	INNER JOIN DDI.SysColumns c ON c.object_id = t.object_id
		AND d.parent_column_id = c.column_id
WHERE db.name = @DatabaseName
    AND d.name <> 'Def_' + t.name + '_' + c.name

IF @Debug = 1
BEGIN
	EXEC DDI.spPrintOutLongSQL 
		@SQLInput = @RenameDefaultConstraints ,
	    @VariableName = N'@RenameDefaultConstraints'
END
ELSE
BEGIN
	EXEC(@RenameDefaultConstraints)
END

GO
