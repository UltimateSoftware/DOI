IF OBJECT_ID('[DDI].[fnActualConstraintsForTable]') IS NOT NULL
	DROP FUNCTION [DDI].[fnActualConstraintsForTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE       FUNCTION [DDI].[fnActualConstraintsForTable](
    @DatabaseName SYSNAME,
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@NameStringReplace SYSNAME = NULL)
RETURNS TABLE
AS RETURN
(

/*
SELECT * 
FROM DDI.fnActualConstraintsForTable('PaymentReporting', 'dbo','Pays', '')
--order by ConstraintName	
except
SELECT *
FROM DDI.fnActualConstraintsForTable('PaymentReporting', 'dbo','Pays_OLD', '_OLD')
order by ConstraintName	
*/

SELECT	d.name AS DatabaseName,
        REPLACE(cc.name, @NameStringReplace, SPACE(0)) AS ConstraintName, 
		cc.type_desc, 
		c.name AS ColumnName, 
		cc.definition
FROM DDI.SysCheckConstraints cc
    INNER JOIN DDI.SysDatabases d ON d.database_id = cc.database_id
	INNER JOIN DDI.SysTables t ON t.object_id = cc.parent_object_id
	INNER JOIN DDI.SysColumns c ON c.object_id = t.object_id
		AND c.column_id = cc.parent_column_id
	INNER JOIN DDI.SysSchemas s ON s.schema_id = t.schema_id
WHERE d.name = @DatabaseName
    AND s.name = @SchemaName
	AND t.name = @TableName
UNION ALL
SELECT	d.name AS DatabaseName,
        REPLACE(dc.name, @NameStringReplace, SPACE(0)) AS ConstraintName, 
		dc.type_desc, 
		c.name AS ColumnName, 
		dc.definition
FROM DDI.SysDefaultConstraints dc
    INNER JOIN DDI.SysDatabases d ON d.database_id = dc.database_id
	INNER JOIN DDI.SysTables t ON t.database_id = d.database_id
        AND t.object_id = dc.parent_object_id
	INNER JOIN DDI.SysColumns c ON c.database_id = t.database_id
        AND c.object_id = t.object_id
		AND c.column_id = dc.parent_column_id
	INNER JOIN DDI.SysSchemas s ON s.database_id = t.database_id
        AND s.schema_id = t.schema_id
WHERE d.name = @DatabaseName
    AND s.name = @SchemaName
	AND t.name = @TableName)

GO
